//
//  ViewController.swift
//  SimpleBrowser
//
//  Created by Kakeru Nakabachi on 2017/05/14.
//  Copyright © 2017年 Kakeru Nakabachi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //ホームページのURL。起動時にこのURLを開く。
    let homeUrlString = "http://www.yahoo.co.jp"
    
    //検索機能で使うURL
    let searchUrlString = "http://search.yahoo.co.jp/search?p="
    
    //URLのホワイトリスト。
    //このURLに当てはまればアプリ内でブラウザ表示許可。
    //前方一致の正規表現で処理される。
    let whiteList = [
        "https?://.*\\.yahoo\\.co\\.jp",
        "https?://.*\\.yahoo\\.com",
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //ホームページを開く。
        open(urlString: homeUrlString)
        webView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //文字列で指定されたURLをWeb Viewで開く。
    func open(urlString: String) {
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
    }
    
    //文字列で指定されたURLをSafariで開く。
    func openInSafari(urlString: String) {
        if let nsUrl = URL(string: urlString) {
            UIApplication.shared.open(nsUrl)
        }
    }
    
    //読込完了時の処理
    func stopLoading(){
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
        backButton.isEnabled = self.webView.canGoBack
        reloadButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    //MARK: - UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.alpha = 1 //Active Indicator Viewの表示(不透明にする)
        activityIndicator.startAnimating() //くるくるのアニメーション開始
        backButton.isEnabled = false //戻る美たんを押せなくする
        reloadButton.isEnabled = false //再読込ボタンを押せなくする
        stopButton.isEnabled = true //読込停止ボタンを押せるようにする
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopLoading()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //Web Viewが読込を開始した時に実行される
        //ユーザの操作によるリクエストでなければ表示許可。
        if navigationType == UIWebViewNavigationType.other {
            return true;
        }
        
        //現在表示中のURLを取得。
        var theUrl: String
        if let unwrappedUrl = request.url?.absoluteString {
            theUrl = unwrappedUrl
        } else {
            //現在表示中のURLが取得できない場合表示不許可。
            stopLoading()
            return false;
        }
        
        //ホワイトリストでループしてURLがホワイトリスト内にあるかチェック。
        var canStayInApp = false;
        for url in whiteList {
            if theUrl.range(of: url, options: NSString.CompareOptions.regularExpression) != nil {
                canStayInApp = true;
                break;
            }
        }
        
        //ホワイトリスト内に無ければSafariで開く。
        if !canStayInApp {
            openInSafari(urlString: theUrl)
            stopLoading()
            return false;
        }
        return true
    }
    
    //MARK: - UISearchBarDelegate
    //SearchBarでユーザが検索ボタンを押したら呼び出される。
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        guard let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        
        let urlString = searchUrlString + encodedText
        open(urlString: urlString)
        searchBar.resignFirstResponder()
    }
    
    //MARK: - IBAction
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
}
