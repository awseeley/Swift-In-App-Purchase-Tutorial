//
//  ViewController.swift
//  SeemuIAPTute


import UIKit
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver{

    @IBOutlet var lblAd: UILabel!
    @IBOutlet var lblCoinAmount: UILabel!
    
    @IBOutlet var outRemoveAds: UIButton!
    @IBOutlet var outAddCoins: UIButton!
    var coins = 50
    
    // 1
    override func viewDidLoad() {
        super.viewDidLoad()
        outRemoveAds.enabled = false
        outAddCoins.enabled = false
        
        // Set IAPS
        if(SKPaymentQueue.canMakePayments()) {
            println("IAP is enabled, loading")
            var productID:NSSet = NSSet(objects: "seemu.iap.addcoins", "seemu.iap.removeads")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            println("please enable IAPS")
        }
        
    }

    // 2
    @IBAction func btnRemoveAds(sender: UIButton) {
        for product in list {
            var prodID = product.productIdentifier
            if(prodID == "seemu.iap.removeads") {
                p = product
                buyProduct()
                break;
            }
        }
        
    }

    // 3
    @IBAction func btnAddCoins(sender: UIButton) {
        for product in list {
            var prodID = product.productIdentifier
            if(prodID == "seemu.iap.addcoins") {
                p = product
                buyProduct()
                break;
            }
        }
        
    }
    
    // 4
    func removeAds() {
        lblAd.removeFromSuperview()
    }
    
    // 5
    func addCoins() {
        coins = coins + 50
        lblCoinAmount.text = "\(coins)"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func RestorePurchases(sender: UIButton) {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    // seemu.iap.removeads
    // seemu.iap.addcoins
    
    func buyProduct() {
        println("buy " + p.productIdentifier)
        var pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("product request")
        var myProduct = response.products
        
        for product in myProduct {
            println("product added")
            println(product.productIdentifier)
            println(product.localizedTitle)
            println(product.localizedDescription)
            println(product.price)
            
            list.append(product as! SKProduct)
        }
        
        outRemoveAds.enabled = true
        outAddCoins.enabled = true
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("transactions restored")
        
        var purchasedItemIDS = []
        for transaction in queue.transactions {
            var t: SKPaymentTransaction = transaction as! SKPaymentTransaction
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "seemu.iap.removeads":
                println("remove ads")
                removeAds()
            case "seemu.iap.addcoins":
                println("add coins to account")
                addCoins()
            default:
                println("IAP not setup")
            }
            
        }
    }

    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("add paymnet")
        
        for transaction:AnyObject in transactions {
            var trans = transaction as! SKPaymentTransaction
            println(trans.error)
            
            switch trans.transactionState {
                
            case .Purchased:
                println("buy, ok unlock iap here")
                println(p.productIdentifier)
                
                let prodID = p.productIdentifier as String
                switch prodID {
                    case "seemu.iap.removeads":
                        println("remove ads")
                        removeAds()
                    case "seemu.iap.addcoins":
                        println("add coins to account")
                        addCoins()
                    default:
                        println("IAP not setup")
                }
                
                queue.finishTransaction(trans)
                break;
            case .Failed:
                println("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                println("default")
                break;
                
            }
        }
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        println("finish trans")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!)
    {
        println("remove trans");
    }

    
    
}

