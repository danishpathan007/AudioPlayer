# AudioPlayer

# Example
    
   func presentAudioPlayerViewController()
      {
          let vc = homeStoryboard.instantiateViewController(withIdentifier: AudioPlayViewController.identifier()) as? AudioPlayViewController
           vc?.audioUrl = audioMessage.url
           vc?.totalDurationInSeconds = audioMessage.duration_in_seconds
           vc?.modalPresentationStyle = .overCurrentContext
           vc?.modalTransitionStyle = .crossDissolve
           self.present(vc!, animated: true, completion: nil)
    }
