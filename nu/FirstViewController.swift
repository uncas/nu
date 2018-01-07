import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeLegend.text = "Intro"
        resetText()
        self.toggleButton.addTarget(nil, action: (#selector(FirstViewController.toggleTimer)), for: .touchDown)
        self.stopButton.addTarget(nil, action: (#selector(FirstViewController.stopTimer)), for: .touchDown)
    }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLegend: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var seconds = 60
    var timer = Timer()
    var isTimerRunning = false

    func toggleTimer(){
        if self.isTimerRunning == false {
            runTimer()
            self.isTimerRunning = true
        } else {
            pauseTimer()
        }
        resetText()
    }

    func updateTimer() {
        seconds -= 1
        setText()
    }

    func setText(){
        self.timeLabel.text = String(seconds)
    }

    func resetText(){
        if self.isTimerRunning == false {
            self.toggleButton.setTitle("Start", for: .normal)
        } else {
            self.toggleButton.setTitle("Pause", for: .normal)
        }
        setText()
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(FirstViewController.updateTimer)), userInfo: nil, repeats: true)
    }

    func pauseTimer(){
        timer.invalidate()
        self.isTimerRunning = false
    }

    func stopTimer(){
        pauseTimer()
        seconds = 60
        resetText()
    }
}
