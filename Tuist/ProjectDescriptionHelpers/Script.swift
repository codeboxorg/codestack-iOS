//
//  Script.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 3/2/24.
//

import ProjectDescription

public extension TargetScript {
    static let BuildScript = TargetScript.pre(script: """
#!/bin/bash
buildDay=$(/usr/libexec/PlistBuddy -c "Print :buildDay" "$INFOPLIST_FILE" 2>/dev/null)
buildCount=$(/usr/libexec/PlistBuddy -c "Print :buildCount" "$INFOPLIST_FILE" 2>/dev/null)
cfBundleVersion=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFOPLIST_FILE" 2>/dev/null)
currentProjectVersion=$(/usr/libexec/PlistBuddy -c "Print :CURRENT_PROJECT_VERSION" "$INFOPLIST_FILE" 2>/dev/null)
today=$(date +%Y%m%d)

if [ -z "$buildDay" ]; then
  buildDay=${today}
  buildCount=1
  printf -v zeroPadBuildCount "%03d" $buildCount
  buildNumber=${buildDay}${zeroPadBuildCount}

  /usr/libexec/PlistBuddy -c "Add :buildDay string "$buildDay"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Add :buildCount string "$buildCount"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string "$buildNumber"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Add :CURRENT_PROJECT_VERSION string "$buildNumber"" "$INFOPLIST_FILE"

elif [ "$buildDay" != "$today" ]; then
  buildDay=${today}
  buildCount=1
  printf -v zeroPadBuildCount "%03d" $buildCount
  buildNumber=${buildDay}${zeroPadBuildCount}

  /usr/libexec/PlistBuddy -c "Set :buildDay "$buildDay"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Set :buildCount "$buildCount"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion "$buildNumber"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Set :CURRENT_PROJECT_VERSION "$buildNumber"" "$INFOPLIST_FILE"

else
  buildCount=$(($buildCount + 1))
  printf -v zeroPadBuildCount "%03d" $buildCount
  buildNumber=${buildDay}${zeroPadBuildCount}

  /usr/libexec/PlistBuddy -c "Set :buildDay "$buildDay"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Set :buildCount "$buildCount"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion "$buildNumber"" "$INFOPLIST_FILE"
  /usr/libexec/PlistBuddy -c "Set :CURRENT_PROJECT_VERSION "$buildNumber"" "$INFOPLIST_FILE"
fi
""", name: "BuildScript", runForInstallBuildsOnly: true)
}
