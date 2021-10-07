//
//  AudioPlayViewController.swift
// 
//
//  Created by Danish Khan on 22/09/21.
//

import UIKit
import AVKit

class AudioPlayViewController: UIViewController {
    
    
    @IBOutlet weak var audioTimeDurationLabel:UILabel!
    @IBOutlet weak var audioCurrentTimeLabel:UILabel!
    @IBOutlet weak var audioPlayButton:ClosureButton!
    @IBOutlet weak var audioHorizontalSlider: UISlider!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var player: AVPlayer!
    private var sliderTimer  = Timer()
    private var isPlayButtonTapped:Bool = false
    private var isRecordButtonTapped:Bool = false
    
    var audioUrl:String?
    var totalDurationInSeconds:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let audioUrl = audioUrl{
            preparePlayer(urlString: audioUrl)
            playSound()
        }
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player?.pause()
    }
    
    @IBAction func audioPlayButtonTapped(_ sender: ClosureButton) {
        playSound()
    }
    
   
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AudioPlayViewController{
    func playSound() {
        if player?.rate == 0{
            player!.play()
            audioPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player!.pause()
            audioPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    
    /*
     Prepare Audio Player
     */
    func preparePlayer(urlString:String) {
        let url = URL.init(string: urlString)!
        let playerItem = AVPlayerItem(url: url)
        self.player =  AVPlayer(playerItem:playerItem)
        /*
         To get overAll duration of the audio
         */
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        audioTimeDurationLabel.text = CommonUtilities.stringFromTimeInterval(interval: TimeInterval(totalDurationInSeconds))
        /*
         To get the current duration of the audio
         */
        let currentDuration : CMTime = playerItem.currentTime()
        let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
        audioCurrentTimeLabel.text = CommonUtilities.stringFromTimeInterval(interval: currentSeconds)
        /*
         AudioHorizontalSlider maximumValue setup
         */
        audioHorizontalSlider.maximumValue = Float(seconds)
        audioHorizontalSlider.isContinuous = true
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) -> Void in

            if self?.player.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                let time:Float64 = CMTimeGetSeconds((self?.player!.currentTime())!)
                self?.audioHorizontalSlider.value = Float(time)
                self?.audioCurrentTimeLabel.text = CommonUtilities.stringFromTimeInterval(interval: time)
                if let isPlaybackLikelyToKeepUp = self?.player.currentItem?.isPlaybackLikelyToKeepUp {
                    if isPlaybackLikelyToKeepUp{
                        self?.hideActivityIndicator()
                    }
                }
                if let isPlayBackBufferEmpty = self?.player?.currentItem?.isPlaybackBufferEmpty{
                    if isPlayBackBufferEmpty{
                        self?.showActivityIndicator()
                    }
                }
            }else{
                if self?.isPlayButtonTapped ?? false{
                    self?.showActivityIndicator()
                }
            }
        }
        /*
         AudioHorizontalSlider Value Changed Target Added Here
         */
        audioHorizontalSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    
    
    private func showActivityIndicator() {
        activityIndicatorView.startAnimating()
        audioPlayButton.isHidden = true
    }
    
    private func hideActivityIndicator() {
        activityIndicatorView.stopAnimating()
        audioPlayButton.isHidden = false
    }
    
    
    /*
     Playback Slider ValueChanged
     */
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            player?.play()
            audioPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }else{
            audioPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    /*
     After finished audio this function call.
     */
    @objc func finishedPlaying( _ myNotification: NSNotification) {
        audioPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        /*
         Reset Audio Horizontal Slider Value
         */
        audioHorizontalSlider.value = 0
        let targetTime:CMTime = CMTimeMake(value: 0, timescale: 1)
        player!.seek(to: targetTime)
    
        /*
         Dismiss view Controller
         */
        
        self.dismiss(animated: true, completion: nil)
    }
   
    
}
