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
    open var volume: Float = 1.0
    
    let numPlayersDepth = 5 //QQQQ this is maybe wastefull.
    
    var avAudioPlayers = [String: [AVAudioPlayer?]]()
    var playerIndex = [String: Int]()
    
    var srmAudioPlayers = [Int: AVAudioPlayer]()
    
    static var playingMusic: Bool = false
    
    func loadSound(fileName: String, key: String){
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(fileName)")
            avAudioPlayers[key] = nil
            return
        }
        var error: NSError? = nil
        do {
            avAudioPlayers[key] = Array<AVAudioPlayer>()
            for _ in 1...numPlayersDepth{
                let player = try AVAudioPlayer(contentsOf: url!)
                player.prepareToPlay() //QQQQ
                avAudioPlayers[key]?.append(player)
                playerIndex[key] = 0
            }
        } catch let error1 as NSError {
            error = error1
            avAudioPlayers[key] = nil
        }
    }
    
    func loadSRM(num: Int){
        let fileNameMP3 = "srm_\(num).mp3"
        let fileNameM4A = "srm_\(num).m4a"
        var url = Bundle.main.url(forResource: fileNameMP3, withExtension: nil)
        if (url == nil) {
            url = Bundle.main.url(forResource: fileNameM4A, withExtension: nil)
            if (url == nil){
                print("Could not find file for SRM: \(num)")
                srmAudioPlayers[num] = nil
                return
            }
        }
        var error: NSError? = nil
        do {
            for _ in 1...numPlayersDepth{
                let player = try AVAudioPlayer(contentsOf: url!)
                srmAudioPlayers[num] = player
                player.prepareToPlay() //QQQQ
                print("loaded \(url!)")
            }
        } catch let error1 as NSError {
            error = error1
            srmAudioPlayers[num] = nil
        }
    }

    func onEnteringForegroud(){
        if SKTAudio.playingMusic{
            resumeBackgroundMusic()
        }
    }
    
    
    func preLoadSounds(){
        loadSound(fileName: "click.wav", key: "buttonClick")
        loadSound(fileName: "knock.wav", key: "wallHit")
        loadSound(fileName: "electricshock.wav", key: "touchBadNode")
        loadSound(fileName: "robotBlip.wav", key: "mathOperator")
        loadSound(fileName: "Hole_Punch.wav", key: "trash")
        loadSound(fileName: "0015_game_event_03_achieve.wav", key: "gotLevel")
        loadSound(fileName: "0015_game_event_02_victory.wav", key: "die")
        
        for i in 1...Int(numSRMVoices){
            loadSRM(num: i)
        }
      }
    
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
        volume = 0.04 //QQQQ constant
        if let player = backgroundMusicPlayer {
            player.volume = volume
        }
    }
    
    open func setHighBackgroundMusicVolume(){
        volume = 0.5 //QQQQ constant
        if let player = backgroundMusicPlayer{
            player.volume = volume
        }

    }
    
    open func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if !player.isPlaying {
                player.play()
            }
        }
    }
    
    open func playSRM(num: Int, volume: Float){
        srmAudioPlayers[num]?.volume = volume
        srmAudioPlayers[num]?.play() //QQQQ underxtand how conditonal unwrapping works
    }
    
    open func playSoundEffect(fromLabel label: String, volume: Float){
        if let playerArray = avAudioPlayers[label]{
            if let index = playerIndex[label]{
                if let player = playerArray[index]{
                    player.numberOfLoops = 0
                    //player.prepareToPlay()
                    player.volume = volume
                    player.play()
                    playerIndex[label] = playerIndex[label]! + 1
                    if playerIndex[label]! == numPlayersDepth{
                        playerIndex[label] = 0
                    }
                }else{
                    print("NO SOUND: \(label)")
                }
            }else{
                print("NO SOUND INDEX: \(label)")
            }
        }else{
            print("NO SOUND ARRAY: \(label)")
        }
    }
}

private let SKTAudioInstance = SKTAudio()
