//
// Created by Aleksandr Grin on 1/22/19.
// Copyright (c) 2019 AleksandrGrin. All rights reserved.
//

import Foundation

let dataPath: URL = {
//1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
    let manager = FileManager.default
//2 - this returns an array of urls from our documentDirectory and we take the first path
    let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
//3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
    let pathOut = url!.appendingPathComponent("GameData").absoluteURL
    return pathOut
}()

struct level:Codable {
    var unlocked:Bool
    var highScore:Int
}

class GameData:Codable {
    private static let sharedData: GameData = loadData()

    var levelData: [level] = []

    //Access the singleton data
    class func sharedInstance() -> GameData {
        return self.sharedData
    }

    enum CodingKeys: String, CodingKey{
        case levelData = "levels"
    }

    private init() {
        self.levelData = {
            var data: [level] = []
            for _ in 0..<100 {
                data.append(level(unlocked: false, highScore: 0))
            }
            data[0].unlocked = true
            return data
        }()
    }

    //Load data from disk or instantiate new.
    class func loadData() -> GameData {
        do{
            let data = try Data(contentsOf: dataPath)
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)

            if let data = unarchiver.decodeDecodable([level].self, forKey: "GameData"){
                let temp = GameData()
                temp.levelData = data
                return temp
            } else {
                //If we are creating a new instance as in the case of a first time launch then
                // we need to populate the leveldata with 100 levels.
                return GameData()
            }
        }catch{
            print("Failed to unarchive data.")
        }
        return GameData()
    }

    //Save the data to disc
    class func saveData() {
        let archiver = NSKeyedArchiver()
        do{
            try archiver.encodeEncodable(GameData.sharedInstance().levelData, forKey: "GameData")
            try archiver.encodedData.write(to: dataPath)
        }catch {
            print("Failed to write data to file \(error.localizedDescription)")
        }
    }

    func encode(with encoder:Encoder){
        do{
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(GameData.sharedInstance().levelData, forKey: CodingKeys.levelData)
        }catch {
            print("Failed to encode data. \(error.localizedDescription)")
        }
    }

    required convenience init(from decoder: Decoder) {
        self.init()
        do{
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.levelData = try values.decode([level].self, forKey: CodingKeys.levelData)
        }catch{
            print("Error decoding")
        }

    }
}