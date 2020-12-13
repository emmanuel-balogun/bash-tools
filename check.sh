#!/bin/bash

#find instances of localisation 
healthKey="HealthLocalizedString(key:"
#extract key from instances of localisation 
#check if extracted key exists in strings
pathToHealth="../members-health-ios-backup/members-health-ios/MembersHealth/Sources/Strings/Health.strings"

#find instances of localisation 
commonKey="CommonLocalizedString(key:"
#extract key from instances of localisation 
#check if extracted key exists in strings
pathToCommon="../members-health-ios-backup/members-health-ios/App/Pods/MembersLocalization/MembersLocalization/Resources/Common.strings"