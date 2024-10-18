//
//  PublicChannelItem.swift
//  WhatsAppClone
//
//  Created by Thomas on 18/10/2024.
//

import Foundation

struct PublicChannelItem: Identifiable {
    let imageUrl: String
    let title: String
    
    var id: String {
        return title
    }
    
    static let placeholders: [PublicChannelItem] = [
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/commons/2/26/Six_eggs_views_from_the_top_on_a_white_background.jpg", title: "Eggs"),
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/en/c/c7/Batman_Infobox.jpg", title: "Batman"),
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/en/d/d8/Game_of_Thrones_title_card.jpg", title: "Game of Thrones"),
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/en/5/5c/Mario_by_Shigehisa_Nakaue.png", title: "Mario"),
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/commons/6/60/Kriek_Beer_1.jpg", title: "Beer"),
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/commons/2/2e/Ice_cream_with_whipped_cream%2C_chocolate_syrup%2C_and_a_wafer_%28cropped%29.jpg", title: "Ice Cream"),
        .init(imageUrl: "https://upload.wikimedia.org/wikipedia/commons/3/3d/8hosomak8.jpg", title: "Sushi")
    ]
}
