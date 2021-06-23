//
//  ViewController.swift
//  WordScramble
//
//  Created by Igor Chernyshov on 23.06.2021.
//

import UIKit

class ViewController: UITableViewController {

	var allWords = [String]()
	var usedWords = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))

		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
		   let startWords = try? String(contentsOf: startWordsURL) {
			allWords = startWords.components(separatedBy: "\n")
		}

		if allWords.isEmpty {
			allWords = ["silkworm"]
		}

		startGame()
	}

	private func startGame() {
		title = allWords.randomElement()
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}

	@objc private func promptForAnswer() {
		let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
		alertController.addTextField()

		let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
			guard let answer = alertController?.textFields?[0].text else { return }
			self?.submit(answer)
		}

		alertController.addAction(submitAction)
		present(alertController, animated: true)
	}

	private func submit(_ answer: String) {
		// TODO: Submit process
	}
}

extension ViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		usedWords.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
		cell.textLabel?.text = usedWords[indexPath.row]
		return cell
	}
}
