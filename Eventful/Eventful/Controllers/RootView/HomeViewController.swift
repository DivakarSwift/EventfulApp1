 
 import UIKit
 import Firebase
 import FirebaseAuth
 import FaceAware
 import  DTPagerController
 
 
 class HomeViewController: UITabBarController,UITabBarControllerDelegate  {
   
    lazy var viewControllerList: [UIViewController] = {
        let homeFeedController = HomeFeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let navController = UINavigationController(rootViewController: homeFeedController)
        navController.tabBarItem.image = UIImage(named: "icons8-home-page-50")?.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.title = "Home"
        navController.tabBarItem.selectedImage = UIImage(named: "icons8-home-page-filled-50")?.withRenderingMode(.alwaysOriginal)

        //        let navController = ScrollingNavigationController(rootViewController: homeFeedController)

        
        let profileView = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileViewNavController = UINavigationController(rootViewController: profileView)
        profileViewNavController.tabBarItem.image = UIImage(named: "icons8-User-50")?.withRenderingMode(.alwaysOriginal)
        profileViewNavController.tabBarItem.title = "Profile"
        profileViewNavController.tabBarItem.selectedImage = UIImage(named: "icons8-User Filled-50")?.withRenderingMode(.alwaysOriginal)

//        let searchController = EventSearchController(collectionViewLayout: UICollectionViewFlowLayout())
//        let searchNavController = UINavigationController(rootViewController: searchController)
        let newSearchController = NewSearchViewController()
        
        newSearchController.tabBarItem.image =  UIImage(named: "icons8-search-50")?.withRenderingMode(.alwaysOriginal)
        newSearchController.tabBarItem.selectedImage =  UIImage(named: "icons8-search-filled-50")?.withRenderingMode(.alwaysOriginal)
        newSearchController.tabBarItem.title = "Search"
        
        let requestVC = RequestViewController()
        let notificationView = NotificationsViewController()
        requestVC.title = "Pending Friend Request"
        notificationView.title = "Activity"

        let pagerController = DTPagerController(viewControllers: [requestVC,notificationView])
        pagerController.title = "Notifications"
        pagerController.font = UIFont(name: "Avenir", size: 14)!
        pagerController.selectedFont = UIFont(name: "Avenir-Medium", size: 14)!
        pagerController.selectedTextColor =  UIColor.black
        pagerController.perferredScrollIndicatorHeight = 1.8
        pagerController.preferredSegmentedControlHeight = 40
        pagerController.scrollIndicator.backgroundColor = UIColor.black
        let notificationNavController = UINavigationController(rootViewController: pagerController)
        notificationNavController.tabBarItem.image = UIImage(named: "icons8-Notification-50")?.withRenderingMode(.alwaysOriginal)
        notificationNavController.tabBarItem.selectedImage = UIImage(named: "icons8-Notification Filled-50")?.withRenderingMode(.alwaysOriginal)
        notificationNavController.tabBarItem.title = "Notifications"
    
        return [navController
            ,newSearchController,notificationNavController,profileViewNavController]
    }()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewControllers = viewControllerList
        guard let items = tabBar.items else {
            return
        }
        for item in items{
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        //will set the defuat index to homeFeedController
    }

 }
 

 

