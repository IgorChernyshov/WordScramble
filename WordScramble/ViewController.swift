//
//  ViewController.swift
//  WordScramble
//
//  Created by Igor Chernyshov on 23.06.2021.
//

import UIKit

final class ViewController: UITableViewController {

	private var currentWord: String = ""
	private var allWords = [String]()
	private var usedWords = [String]()

	private enum Constant {
		static let savedWord = "savedWord"
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))

		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
		   let startWords = try? String(contentsOf: startWordsURL) {
			allWords = startWords.components(separatedBy: "\n")
		}

		loadGame()
	}

	private func loadGame() {
		guard let savedWord = UserDefaults.standard.string(forKey: Constant.savedWord) else { return startGame() }
		configureGame(word: savedWord)
	}

	@objc private func startGame() {
		UserDefaults.standard.setValue([], forKey: currentWord)
		guard let randomWord = allWords.randomElement()?.lowercased() else { fatalError("Words are missing") }
		UserDefaults.standard.setValue(randomWord, forKey: Constant.savedWord)
		configureGame(word: randomWord)
	}

	private func configureGame(word: String) {
		currentWord = word
		title = currentWord
		usedWords.removeAll(keepingCapacity: true)
		usedWords = UserDefaults.standard.array(forKey: currentWord) as? [String] ?? []
		tableView.reloadData()
	}

	@objc private func promptForAnswer() {
		let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
		alertController.addTextField()

		let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in
			guard let answer = alertController?.textFields?[0].text else { return }
			self?.submit(answer: answer)
		}

		alertController.addAction(submitAction)
		present(alertController, animated: true)
	}

	private func submit(answer: String) {
		let lowercasedAnswer = answer.lowercased()

		guard isLongEnough(word: lowercasedAnswer) else {
			return showError(title: "Word is too short", message: "Your word must have three letters or more")
		}
		guard isPossible(word: lowercasedAnswer) else {
			return showError(title: "Word not possible", message: "You can't spell that word from \(currentWord)")
		}
		guard isOriginal(word: lowercasedAnswer) else {
			return showError(title: "Word used already", message: "Be more original!")
		}
		guard isReal(word: lowercasedAnswer) else {
			return showError(title: "Word not recognised", message: "You can't just make them up, you know!")
		}

		usedWords.insert(lowercasedAnswer, at: 0)
		UserDefaults.standard.set(usedWords, forKey: currentWord)
		let indexPath = IndexPath(row: 0, section: 0)
		tableView.insertRows(at: [indexPath], with: .automatic)
	}

	private func isLongEnough(word: String) -> Bool {
		word.count >= 3
	}

	private func isPossible(word: String) -> Bool {
		var tempWord = currentWord

		for letter in word {
			if let position = tempWord.firstIndex(of: letter) {
				tempWord.remove(at: position)
			} else {
				return false
			}
		}

		return true
	}

	private func isOriginal(word: String) -> Bool {
		word != currentWord && !usedWords.contains(word)
	}

	private func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

		return misspelledRange.location == NSNotFound
	}

	private func showError(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default))
		present(alertController, animated: true)
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
