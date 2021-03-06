//
//  NotificationsProtocol.swift
//  Capable
//
//  Created by Christoph Wendt on 30.03.18.
//

protocol NotificationsProtocol {
    init(statusesModule: StatusesProtocol, notificationCenter: NotificationCenter)
    func postNotification(withFeature feature: CapableFeature, statusString: String)
}
