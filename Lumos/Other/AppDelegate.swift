//
//  AppDelegate.swift
//  Lumos
//
//  Created by Christoph Pageler on 07.07.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var settingsWindowController: NSWindowController? = nil
    var presentationWindowController: PresentationWC? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FolderBookmarkService.shared.loadBookmarks()
        Preferences.checkImageFolderPath()
        Server.shared.start()
        let _ = FolderWatch.shared
        ImageService.shared.cleanImageStore()

        // Load Settings VC
        let storyboard = NSStoryboard(name: "Main" , bundle: nil)
        let identifier = "SettingsVC"
        settingsWindowController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController

        if !FileManager.default.isWritableFile(atPath: Preferences.imagesFolderPath.path) {
            openPreferences(self)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "settingsShouldChooseFolder"),
                                                object: nil)
            }
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard filename.hasSuffix(".lms") else { return false }
        let fileURL = URL(fileURLWithPath: filename)
        Preferences.databaseName = fileURL.lastPathComponent
        Preferences.imagesFolderPath = fileURL.deletingLastPathComponent()
        Preferences.sendPreferencesUpdate()
        return true
    }

    @IBAction func openPreferences(_ sender: Any) {
        settingsWindowController?.showWindow(nil)
    }

    @IBAction func showPresentation(_ sender: NSMenuItem) {
        presentationWindowController?.showWindow(nil)
    }

}

