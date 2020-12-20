#!/bin/bash

#find instances of key string in health localisation using the following pattern: 
#healthKey="HealthLocalizedString(key:"
#extract key from instances of localisation 
#check if extracted key exists in strings
pathToHealth="../members-health-ios-backup/members-health-ios/MembersHealth/Sources/Strings/Health.strings"

#find instances of key string in health localisation using the following pattern: 
#commonKey="CommonLocalizedString(key:"
#extract key from instances of localisation 
#check if extracted key exists in strings
pathToCommon="../members-health-ios-backup/members-health-ios/App/Pods/MembersLocalization/MembersLocalization/Resources/Common.strings"