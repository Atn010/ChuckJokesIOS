//
//  ViewController.swift
//  ChuckJokes
//
//  Created by Antonius George on 28/09/18.
//  Copyright © 2018 Atn010. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
	
	@IBOutlet weak var appLogoImage: UIImageView!
	@IBOutlet weak var jokeTextLabel: UILabel!
	@IBOutlet weak var statusTextLabel: UILabel!
	@IBOutlet weak var getJokeButton: UIButton!
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var managedObjectContext : NSManagedObjectContext!
	
	var chuckJokes:[String] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		
		jokeTextLabel.text = "The Chuck is waiting for you. Probably you should click the button."
		
		statusTextLabel.text = "Click the Button to get some Kick!"
		
		getJokeButton.layer.borderColor = getJokeButton.tintColor.cgColor
		getJokeButton.layer.borderWidth = 1
		getJokeButton.setTitle("Get Chuck Noris Jokes", for: .normal)
		
	}
	
	@IBAction func onClickingJokeButton(_ sender: UIButton) {
		getJokeButton.isEnabled = false
		retrieveJoke()
	}
	
	
	func retrieveJoke() {
		statusTextLabel.text = "Getting a Joke from the Chuck"
		//guard let rateURL = URL(string: "https://api.chucknorris.io/jokes/random") else { return }
		guard let rateURL = URL(string: "http://localhost:3002/fortune/2") else { return }
		//guard let rateURL = URL(string: "http://atn010.com/webjsondatabase.github.io/") else { return }
		let session = URLSession(configuration: .ephemeral)
		
		//session.configuration.timeoutIntervalForResource = TimeInterval.init(exactly: 3)!
		
		let dataTask = session.dataTask(with: rateURL) { (data, response, error) in
			
			if let unwrapperError = error{
				print("URLSession Error = /n \(unwrapperError.localizedDescription)")
				
				if self.chuckJokes.isEmpty{
					self.loadSavedJokes()
					self.displayChuckJokes()
				}else{
					self.displayChuckJokes()
				}
				
			}else if let unwrappedData = data{
				self.chuckJokes.removeAll()
				//print(unwrappedData)
				do{
					let jsonFile = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
					
					print(jsonFile)
					
					if let jsonDictionary = jsonFile as? [String:Any]{
						
						
						let jokeID = jsonDictionary["id"] as! String
						//let jokeText = jsonDictionary["value"] as! String
						let jokeText = jsonDictionary["value"] as! String
						//let jokeText = jsonDictionary["joke"] as! String
						DispatchQueue.global(qos: .utility).async {
						//	self.checkJokeID(id: jokeID, text: jokeText)
						}
						print(jsonDictionary)
						print("\n\n")
						print(jokeID)
						print(jokeText)
						
						
						DispatchQueue.main.async {
							
							//self.jokeTextLabel.text = jokeText
							//self.statusTextLabel.text = "BAM! Click the bottom for more!"
							//self.getJokeButton.isEnabled = true
						}

						
					}
					
					
				}catch{
					print("Error Converting code")
				}
				
				
				
			}
			
		}
		
		dataTask.resume()
	}
	
	func displayChuckJokes() {
		//let number = Int.random(in: 0...chuckJokes.count-1)
		print(chuckJokes.count)
		DispatchQueue.main.async {
			
			self.jokeTextLabel.text = self.chuckJokes[0]
			self.statusTextLabel.text = "A Chuck from the past!, just \(self.chuckJokes.count) left"
			self.getJokeButton.isEnabled = true
		}
		chuckJokes.removeFirst()
		
	}
	
	func checkJokeID(id:String,text:String) {
		
		
		
		let noteRequest:NSFetchRequest<ChuckJokes> = ChuckJokes.fetchRequest()
		var count = 0
		
		do {
			let result = try managedObjectContext.fetch(noteRequest)
			for data in result as [NSManagedObject] {
				if data.value(forKey: "id") as! String == id{
					count += 1
				}
				
				
			}
			
			if count == 0{
				
				let cJokes = ChuckJokes(context: managedObjectContext)
				
				cJokes.id = id
				cJokes.text = text
				
				do{
					try self.managedObjectContext.save()
				}catch{
					
				}
				
			}
			
		} catch {
			
			print("Failed Reading")
		}
		
	}
	
	func loadSavedJokes() {
		//statusTextLabel.text = "Internet seems down, Getting Chuck from history"
		
		let noteRequest:NSFetchRequest<ChuckJokes> = ChuckJokes.fetchRequest()
		
		do {
			let result = try managedObjectContext.fetch(noteRequest)
			for data in result as [NSManagedObject] {
				print(data.value(forKey: "id") as! String)
				chuckJokes.append(data.value(forKey: "text") as! String)
				
			}
			chuckJokes.shuffle()
			
		} catch {
			
			print("Failed Loading")
		}
		
	}
	
	
}

