//
//  CoinManager.swift
//  ByteCoinPrice
//
//  Created by Sai Reddy on 09/08/21.
//

import Foundation

protocol CoinManagerDelegate{
    
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "CDCFADED-A049-4371-AA76-8A30571CAF70"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getUrlString(in currency: String) -> String{
        let url = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        return url
    }
    
    func getCoinPrice(for currency: String){
        if let url = URL(string: getUrlString(in: currency)){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                        }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
//            print(lastPrice)
            return lastPrice
        }catch{
            //error
            return nil
        }
    }
    

}
