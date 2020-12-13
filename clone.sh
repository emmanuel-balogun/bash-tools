#!/bin/bash
pathToHealth="../members-health-ios-backup/members-health-ios/MembersHealth/Sources/Strings/Health.strings"
pathToCommon="../members-health-ios-backup/members-health-ios/App/Pods/MembersLocalization/MembersLocalization/Resources/Common.strings"

pathToGlueCodeGen="../members-health-ios-backup/members-health-ios/string_gen.sh"
pathToMembersHealth="../members-health-ios-backup/members-health-ios"
samples="samples.txt"

matches=""
totalRepeatedStrings=0
totalRepeatitions=0

function findDuplications {
  echo -n "" > log.txt
  while IFS= read -r line
  do
    #all cases if more than one and not already printed
    countInHealth=$(grep -c "$line;" $pathToHealth | cut -d= -f2)
    coutnInCommon=$(grep -c "$line;" $pathToCommon | cut -d= -f2)
    total=$(( countInHealth + coutnInCommon ))

    inmatches=$(grep -c "$line, " <<< "$matches" | cut -d= -f2)

    [[ -s "$samples" ]] && insamples=$(grep -c "$line" $samples | cut -d= -f2) || insamples=1

    if [ "$total" -gt 1 ] && [ "$inmatches" -lt 1 ] && [ "$insamples" -gt 0 ]
    then
      matches+="$line, "

      echo "--------------------------------------" >> log.txt
      echo "There are $total repetitions of $line" >> log.txt
      echo "--------------------------------------" >> log.txt
      grep -n "$line;" $pathToHealth $pathToCommon >> log.txt

      if [ "$coutnInCommon" -eq 0 ]
      then
        echo "------------------HEALTH ONLY------------------"
        duplicateLines=$(grep "$line;" $pathToHealth)
        echo "$duplicateLines"
        newKey=""
        echo "Enter generic key OR press [RETURN] to skip: "
        read </dev/tty newKey
        if [ "$newKey" != "" ]
        then
          echo "Removing old keys in health string"
          removeOldKeysFromHealth "$duplicateLines"
          
          echo "Replacing old keys in members health"
          replaceKeys "$duplicateLines" "\"$newKey\""

          echo "Running glue code gen"
          linewithoutsufix="${line%\"}"
          linewithoutqoutes="${linewithoutsufix#\"}"
          echo "line: $linewithoutqoutes"
          sh $pathToGlueCodeGen $newKey "$linewithoutqoutes" >> log.txt
        fi
      fi

      if [ "$countInHealth" -gt 0 ] && [ "$coutnInCommon" -eq 1 ]
      then
        echo "-----------------HEALTH AND 1 COMMON-------------------"
        duplicateCommonLines=$(grep "$line;" $pathToCommon)
        duplicateHealthLines=$(grep "$line;" $pathToHealth)
        echo "$duplicateHealthLines"
        echo "$duplicateCommonLines"

        echo "line: $duplicateCommonLines"
        newKey=$(sed 's/[[:space:]]=.*//' <<< $duplicateCommonLines)
        newKeywithoutsufix="${newKey%\"}"
        newKeywithoutqoutes="${newKeywithoutsufix#\"}"

        echo "Removing old keys in health string"
        removeOldKeysFromHealth "$duplicateHealthLines"
        
        echo "Replacing old keys in members health with $newKey ..."
        replaceKeys "$duplicateHealthLines" "$newKey"

        healthKey="HealthLocalizedString(@$newkey"
        commonKey="CommonLocalizedString(@$newkey"
        echo ">>>> $healthKey"
        grep -rl "$healthKey" $pathToMembersHealth | xargs sed -i '' -e "s/$healthKey/$commonKey/g"
        
        healthKey="HealthLocalizedString(key: $newkey"
        commonKey="CommonLocalizedString(key: $newkey"
        echo ">>>> $healthKey"
        grep -rl "$healthKey" $pathToMembersHealth | xargs sed -i '' -e "s/$healthKey/$commonKey/g"
        
        sh $pathToGlueCodeGen >> log.txt
      fi

      totalRepeatitions=$(($totalRepeatitions + $total))
      totalRepeatedStrings=$(($totalRepeatedStrings + 1))
    fi
  done < <(sed -n 's/.*= \(.*\);/\1/p' $pathToHealth $pathToCommon)

  echo "--------------------------------------" >> log.txt
  echo "GENERAL STATISTICS:" >> log.txt
  echo "--------------------------------------" >> log.txt
  echo "number of repeated strings:$totalRepeatedStrings" >> log.txt
  echo "number of repetitions:$totalRepeatitions" >> log.txt
  echo "all matched strings: $matches"  >> log.txt
}

function removeOldKeysFromHealth {
  while IFS= read -r oldkey
  do
    lineNumber=$(grep -n -B 1 $oldkey $pathToHealth | head -n 1 | sed 's/-..*//g')
    startingLineNumber=$(($lineNumber - 1))
    sed -i.bak -e "$(($lineNumber - 1)),$(($lineNumber + 1))d" $pathToHealth
  done < <(sed 's/[[:space:]]=.*//' <<< $1)
}

function replaceKeys {
  newkey="$2"
  while IFS= read -r oldkey
  do
    echo "replacing $oldkey"
    grep -rl "$oldkey" $pathToMembersHealth | xargs sed -i '' -e "s/$oldkey/$newkey/g"
  done < <(sed 's/[[:space:]]=.*//' <<< $1)
}

function commit {
  git -C $pathToMembersHealth commit -am "$1"
}

findDuplications

echo "================= THANKS FOR USING ===================="
echo "You might not think that programmers are artists," 
echo "but programming is an extremely creative profession." 
echo "It's logic-based creativity."
echo "~John Romero"
exit 1