import UIKit
import AVFoundation

protocol ListenToTimerDelegate: class {
    func didFinishTimer()
}

@objc class MeditationTimer: NSObject {
    var seconds: Int = 0
    var timer = Timer()
    var isRunning = false
    weak var delegate: ListenToTimerDelegate?
    var initialMinutes: Int = 1

    var label: UILabel!

    init(withLabel label: UILabel, minutes: Int, delegate: ListenToTimerDelegate) {
        self.label = label
        self.delegate = delegate
        self.initialMinutes = minutes
        self.seconds = minutes * 10
    }

    func toggle() {
        if self.isRunning == false {
            start()
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
        self.isRunning = true
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func pause() {
        timer.invalidate()
        self.isRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
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
        self.seconds = self.initialMinutes * 60
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
            delegate?.didFinishTimer()
        }
    }
}

class FirstViewController: UIViewController, ListenToTimerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleButton.addTarget(
                nil, action: (#selector(FirstViewController.toggleTimer)), for: .touchDown)
        self.stopButton.addTarget(
                nil, action: (#selector(FirstViewController.stopTimer)), for: .touchDown)
        // 45s forberedelse, 11m, 11m, 11m, 10s
        self.steps = [TimerStep("Intro", 1), TimerStep("Fase 1", 2)]
        initializeTimer()
        resetText()
    }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLegend: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var timer: MeditationTimer? = nil
    var steps: [TimerStep] = []
    var currentStepIndex: Int = 0

    private func initializeTimer() {
        let currentStep = self.steps[self.currentStepIndex]
        let minutes = currentStep.minutes
        self.timer = MeditationTimer(withLabel: timeLabel, minutes: minutes, delegate: self)
    }

    func toggleTimer() {
        timer!.toggle()
        resetText()
    }

    func resetText() {
        self.timeLegend.text = self.steps[self.currentStepIndex].name
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

    func didFinishTimer() {
        if self.currentStepIndex == self.steps.count - 1 {
            return
        }

        self.currentStepIndex += 1
        self.initializeTimer()
        self.toggleTimer()
    }
}