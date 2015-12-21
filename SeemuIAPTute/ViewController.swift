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
            print("IAP is enabled, loading")
            let productID:NSSet = NSSet(objects: "seemu.iap.addcoins", "seemu.iap.removeads")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
        
    }

    // 2
    @IBAction func btnRemoveAds(sender: UIButton) {
        for product in list {
            let prodID = product.productIdentifier
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
            let prodID = product.productIdentifier
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
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product )
        }
        
        outRemoveAds.enabled = true
        outAddCoins.enabled = true
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("transactions restored")
        
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction 
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "seemu.iap.removeads":
                print("remove ads")
                removeAds()
            case "seemu.iap.addcoins":
                print("add coins to account")
                addCoins()
            default:
                print("IAP not setup")
            }
            
        }
    }

    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add paymnet")
        
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            switch trans.transactionState {
                
            case .Purchased:
                print("buy, ok unlock iap here")
                print(p.productIdentifier)
                
                let prodID = p.productIdentifier as String
                switch prodID {
                    case "seemu.iap.removeads":
                        print("remove ads")
                        removeAds()
                    case "seemu.iap.addcoins":
                        print("add coins to account")
                        addCoins()
                    default:
                        print("IAP not setup")
                }
                
                queue.finishTransaction(trans)
                break;
            case .Failed:
                print("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                print("default")
                break;
                
            }
        }
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        print("finish trans")
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
    }
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
    {
        print("remove trans");
    }

    
    
}

