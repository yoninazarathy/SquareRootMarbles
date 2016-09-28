/*
 * Copyright (c) 2013-2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AVFoundation

/**
 * Audio player that uses AVFoundation to play looping background music and
 * short sound effects. For when using SKActions just isn't good enough.
 */
open class SKTAudio {
    open var backgroundMusicPlayer: AVAudioPlayer?
    
    //QQQQ doc and clean up this triple buffer thing...
    open var soundEffectPlayers: [AVAudioPlayer?] = [nil,nil,nil,nil,nil,nil,nil] //7 of them
    open var currentPlayer = 0
    
    open class func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    open func playBackgroundMusic(_ filename: String, volume: Float) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url!)
            backgroundMusicPlayer?.volume = volume
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
        }
        if let player = backgroundMusicPlayer {
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    open func pauseBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if player.isPlaying {
                player.pause()
            }
        }
    }
    
    open func setLowBackgroundMusicVolume(){
        backgroundMusicPlayer!.volume = 0.05
    }
    
    open func setHighBackgroundMusicVolume(){
        backgroundMusicPlayer!.volume = 0.8
    }
    
    
    open func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if !player.isPlaying {
                player.play()
            }
        }
    }
    
    open func playSoundEffect(_ filename: String, volume: Float) {
        
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayers[currentPlayer] = try AVAudioPlayer(contentsOf: url!)
            soundEffectPlayers[currentPlayer]?.volume = volume
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayers[currentPlayer] = nil
            print("error: catching AVAudioPlayer: \(error)")
        }
        if let player = soundEffectPlayers[currentPlayer] {
            player.numberOfLoops = 0
            player.prepareToPlay() //QQQQ Do this ahead of time
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
        currentPlayer = currentPlayer + 1
        if currentPlayer > 7-1{ //QQQQ cleanup
            currentPlayer = 0
        }
    }
}

private let SKTAudioInstance = SKTAudio()