//
//  RocketDetailViewController.swift
//  CleanSpaceX
//
//  Created by Ahmed Iqbal on 3/23/22.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import ImageSlideshow
import SafariServices

protocol RocketDetailDisplayLogic: AnyObject
{
    func displayRocketDetail(viewModel: RocketDetail.GetRocketDetail.ViewModel)
}

class RocketDetailViewController: UIViewController, RocketDetailDisplayLogic
{
    var interactor: RocketDetailBusinessLogic?
    var router: (NSObjectProtocol & RocketDetailRoutingLogic & RocketDetailDataPassing)?
    
    var rocket = Rocket()
    var kingFisherSource:[KingfisherSource] = []
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var labelFirstFlight: UILabel!
    @IBOutlet weak var labelCountry: UILabel!
    @IBOutlet weak var labelSuccessRate: UILabel!
    @IBOutlet weak var labelRocketName: UILabel!
    @IBOutlet weak var labelMass: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonWiki: UIButton!
    
    @IBAction func buttonWikiPressed(_ sender: UIButton) {
        
        guard let urlToLoad = URL(string: rocket.wikipedia ?? "") else {
            return
        }
        let safariVC = SFSafariViewController(url: urlToLoad)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = RocketDetailInteractor()
        let presenter = RocketDetailPresenter()
        let router = RocketDetailRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getRocketDetail()
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func setupViews() {
        buttonWiki.setTitle("", for: .normal)
    }
    
    func setupSlideShow(){
        
        slideShow.slideshowInterval = 5.0
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideShow.activityIndicator = DefaultActivityIndicator()
        slideShow.delegate = self
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideShow.setImageInputs(kingFisherSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(RocketDetailViewController.didTap))
        slideShow.addGestureRecognizer(recognizer)
    }
    
    func populateSlideShow(){
        if let flickerImages = rocket.flickr_images {
            for image in flickerImages{
                kingFisherSource.append(KingfisherSource(urlString: image)!)
            }
        }
    }
    
    func populateRocketDetails(){
        labelFirstFlight.text = "First Flight \(rocket.first_flight ?? "")"
        labelCountry.text = "Country: \(rocket.country ?? "")"
        labelSuccessRate.text = "Success Rate: \(rocket.success_rate_pct ?? 0)%"
        labelRocketName.text = "Rocket Name: \(rocket.rocket_name ?? "")"
        labelMass.text = "Mass \(rocket.mass?.lb ?? 0) lb"
        labelDescription.text = "\(rocket.description ?? "")"
        self.title = rocket.rocket_name
    }
    
    @objc func didTap() {
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func getRocketDetail() {
        let request = RocketDetail.GetRocketDetail.Request()
        interactor?.getRocketDetail(request: request)
    }
    
    func displayRocketDetail(viewModel: RocketDetail.GetRocketDetail.ViewModel)
    {
        if let rocket = viewModel.rocket {
            self.rocket = rocket
            self.populateSlideShow()
            self.setupSlideShow()
            self.populateRocketDetails()
        }
    }
}


extension RocketDetailViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
