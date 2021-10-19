//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapDirectTests: OrcaSwapSwapTests {
    // MARK: - Direct SOL to SPL
    func testDirectSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to created SOCN
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: socnPubkey,
            bestPoolsPair: [socnSOLStableAquafarmsPool.reversed],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSOLToUncreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to uncreated
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [solNinjaAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SOL
    func testDirectSwapSPLToSOL() throws {
        let amount: Double = 0.001 // 0.001 SOCN to Native SOL
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: solPubkey,
            bestPoolsPair: [socnSOLStableAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SPL
    func testDirectSwapSPLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOCN to USDC
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: usdcPubkey,
            bestPoolsPair: [socnUSDCAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSPLToUncreatedSPL() throws {
        let amount: Double = 0.1 // 0.1 USDC to MNGO
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: usdcPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [usdcMNGOAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
}

