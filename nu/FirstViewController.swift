import UIKit
import AVFoundation

struct MeditationConstants {
    static let duration = 11 * 60
}

@objc class MeditationTimer: NSObject {
    var seconds = MeditationConstants.duration
    var timer = Timer()
    var isRunning = false

    var label: UILabel!

    init(withLabel label: UILabel) {
        self.label = label
    }

    func toggle() {
        if self.isRunning == false {
            start()
            self.isRunning = true
        } else {
            pause()
        }
        setText()
    }

    func start() {
        timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: (#selector(MeditationTimer.update)),
                userInfo: nil,
                repeats: true)
    }

    func pause() {
        timer.invalidate()
        self.isRunning = false
    }

    func setText() {
        label.text = timeString(time: TimeInterval(seconds))
    }

    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

    func stop() {
        pause()
        seconds = MeditationConstants.duration
        setText()
    }

    func update() {
        seconds -= 1
        setText()
        if (seconds == 0) {
            pause()
            // https://github.com/TUNER88/iOSSystemSoundsLibrary
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let tweet: SystemSoundID = 1016
            AudioServicesPlaySystemSound(tweet)
        }
    }
}

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeLegend.text = "Intro"
        self.timer = MeditationTimer(withLabel: timeLabel)
        resetText()
        self.toggleButton.addTarget(
                nil, action: (#selector(FirstViewController.toggleTimer)), for: .touchDown)
        self.stopButton.addTarget(
                nil, action: (#selector(FirstViewController.stopTimer)), for: .touchDown)
    }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLegend: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var timer: MeditationTimer? = nil

    func toggleTimer() {
        timer!.toggle()
        resetText()
    }

    func resetText() {
        if self.timer!.isRunning == false {
            self.toggleButton.setTitle("Start", for: .normal)
        } else {
            self.toggleButton.setTitle("Pause", for: .normal)
        }
        timer!.setText()
    }

    func stopTimer() {
        timer!.stop()
        resetText()
    }
}
