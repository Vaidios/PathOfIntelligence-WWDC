//
//  ViewController.swift
//  BrainVisualizationInSpriteKit
//
//  Created by Kamil Sosna on 07/05/2020.
//  Copyright © 2020 Pine. All rights reserved.
//

import UIKit
import SpriteKit


public class BrainViewController: UIViewController {

    let themeColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    var mainNeuView: UIView!
    var mainSKView: SKView!
    var currentScene: SKScene! {
        didSet {
            if currentScene != nil {
                mainSKView.presentScene(currentScene)
            } else {
                mainSKView.presentScene(nil)
            }
        }
    }
    var currentSceneIndex = 0 {
        didSet {
            if currentSceneIndex > 2 {
                currentSceneIndex = 2
            }
            if currentSceneIndex < 0 {
                currentSceneIndex = 0
            }
            if currentSceneIndex == 0 {
                
            }
            currentScene = nil
            switch currentSceneIndex {
            case 0:
                if !buttonsHidden {
                    previousButton.isHidden = true
                    nextButton.isHidden = false
                }
                currentBrain = nil
                currentScene = FirstScene(size: mainSKView.frame.size, completion: { [weak self] in
                guard let self = self else { return }
                self.currentSceneIndex = 1
                })
                return
            case 1:
                if !buttonsHidden {
                    previousButton.isHidden = false
                    nextButton.isHidden = false
                }
                currentBrain = nil
                currentBrain = Brain(brainMap: BitmapManager.cleanCanvasMap, mask: BitmapManager.getMask(BitmapManager.cleanCanvasMap), direction: .down)
                currentScene = SecondScene(size: mainSKView.frame.size, brain: currentBrain, onBack: nil, onForward: nil, onFinish: { [weak self] in
                    guard let self = self else { return }
                    self.currentSceneIndex = 2
                })
                currentScene.backgroundColor = themeColor
            case 2:
                if !buttonsHidden {
                    previousButton.isHidden = false
                    nextButton.isHidden = true
                }

                currentBrain = nil
                currentBrain = Brain(brainMap: BitmapManager.getMap(for: .brain), mask: BitmapManager.getMap(for: .mask))
                currentScene = ThirdScene(size: mainSKView.frame.size, brain: currentBrain, onBack: nil) { [weak self] in
                    guard let self = self else { return }
                    self.buttonsHidden = false
                }
                currentScene.backgroundColor = themeColor
            default:
                return
            }
        }
    }
    public var buttonsHidden: Bool = true {
        didSet {
            if buttonsHidden {
                previousButton.isHidden = true
                nextButton.isHidden = true
            } else {
                previousButton.isHidden = false
                nextButton.isHidden = true
            }
        }
    }
    var currentBrain: Brain!
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = themeColor
        setupNeuView()
        addToNeuView()
        setupButtons()
        buttonsHidden = true
    }
    
    func addToNeuView() {
        let padding: CGFloat = 5
        mainSKView = SKView(frame: CGRect(x: mainNeuView.frame.minX + padding, y: mainNeuView.frame.minY + padding, width: mainNeuView.frame.width - 2 * padding, height: mainNeuView.frame.height - 2 * padding))
        mainSKView.backgroundColor = themeColor
        mainNeuView.addSubview(mainSKView)
        mainSKView.layer.cornerRadius = 0
        mainSKView.clipsToBounds = true
        mainSKView.layer.masksToBounds = true
        view.addSubview(mainSKView)
        
    }
    var previousButton: NeuButton!
    var nextButton: NeuButton!
    func setupButtons() {
        
        previousButton = NeuButton(frame: CGRect(x: mainNeuView.frame.minX + 16, y: mainNeuView.frame.maxY - 60, width: 44, height: 44))
        let config = UIImage.SymbolConfiguration(scale: .medium)
        let leftArrow = UIImage(systemName: "arrow.left", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        previousButton.setImage(leftArrow, for: .normal)
        previousButton.addTarget(self, action: #selector(previousAction(_:)), for: .touchUpInside)
        view.addSubview(previousButton)
        
        nextButton = NeuButton(frame: CGRect(x: mainNeuView.frame.maxX - 60, y: mainNeuView.frame.maxY - 60, width: 44, height: 44))
        let rightArrow = UIImage(systemName: "arrow.right", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        nextButton.setImage(rightArrow, for: .normal)
        nextButton.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        view.addSubview(nextButton)
        currentSceneIndex = 0
    }

    
    @objc func nextAction(_ button: NeuButton) {
        currentSceneIndex += 1
    }
    @objc func previousAction(_ button: NeuButton) {
        currentSceneIndex -= 1
    }
}

extension BrainViewController {
    func setupNeuView(with color: UIColor = UIColor(red: 48/255, green: 49/255, blue: 53/255, alpha: 1.0)) {
        mainNeuView = UIView(frame: CGRect(x: 10, y: 10, width: view.frame.width - 20, height: view.frame.width - 20))
        let cornerRadius: CGFloat = 15
        mainNeuView.layer.cornerRadius = cornerRadius
        mainNeuView.layer.masksToBounds = false
        mainNeuView.layer.shadowRadius = 2
        mainNeuView.layer.shadowOpacity = 1
        mainNeuView.layer.shadowOffset = CGSize( width: 5, height: 5)
        mainNeuView.layer.shadowColor = UIColor(red: 62/255, green: 63/255, blue: 70/255, alpha: 1.0).cgColor
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = mainNeuView.bounds
        shadowLayer.backgroundColor = color.cgColor
        shadowLayer.shadowColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1).cgColor
        shadowLayer.cornerRadius = cornerRadius
        shadowLayer.shadowOffset = CGSize(width: -5.0, height: -5.0)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 2
        mainNeuView.layer.insertSublayer(shadowLayer, at: 0)
        view.addSubview(mainNeuView)
    }
}

