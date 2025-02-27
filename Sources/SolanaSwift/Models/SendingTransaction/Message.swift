//
//  Message2.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/04/2021.
//

import Foundation

extension SolanaSDK.Transaction {
    struct Message {
        // MARK: - Constants
        private static let RECENT_BLOCK_HASH_LENGTH = 32
        
        // MARK: - Properties
        var accountKeys: [SolanaSDK.Account.Meta]
        var recentBlockhash: String
//        var instructions: [Transaction.Instruction]
        var programInstructions: [SolanaSDK.TransactionInstruction]
        
        func serialize() throws -> Data {
            // Header
            let header = encodeHeader()
            
            // Account keys
            let accountKeys = encodeAccountKeys()
            
            // RecentBlockHash
            let recentBlockhash = encodeRecentBlockhash()
            
            // Compiled instruction
            let compiledInstruction = try encodeInstructions()
            
            // Construct data
//            let bufferSize: Int =
//                Header.LENGTH // header
//                + keyCount.count // number of account keys
//                + Int(accountKeys.count) * PublicKey.LENGTH // account keys
//                + RECENT_BLOCK_HASH_LENGTH // recent block hash
//                + instructionsLength.count
//                + compiledInstructionsLength
            
            var data = Data(/*capacity: bufferSize*/)
            
            // Append data
            data.append(header)
            data.append(accountKeys)
            data.append(recentBlockhash)
            data.append(compiledInstruction)
            
            return data
        }
        
        private func encodeHeader() -> Data {
            var header = Header()
            for meta in accountKeys {
                if meta.isSigner {
                    // signed
                    header.numRequiredSignatures += 1
                    
                    // signed & readonly
                    if !meta.isWritable {
                        header.numReadonlySignedAccounts += 1
                    }
                } else {
                    // unsigned & readonly
                    if !meta.isWritable {
                        header.numReadonlyUnsignedAccounts += 1
                    }
                }
            }
            return Data(header.bytes)
        }
        
        private func encodeAccountKeys() -> Data {
            // length
            let keyCount = encodeLength(accountKeys.count)
            
            // construct data
            var data = Data(capacity: keyCount.count + accountKeys.count * SolanaSDK.PublicKey.numberOfBytes)
            
            // sort
            let signedKeys = accountKeys.filter {$0.isSigner}
            let unsignedKeys = accountKeys.filter {!$0.isSigner}
            let accountKeys = signedKeys + unsignedKeys
            
            // append data
            data.append(keyCount)
            for meta in accountKeys {
                data.append(meta.publicKey.data)
            }
            return data
        }
        
        private func encodeRecentBlockhash() -> Data {
            Data(Base58.decode(recentBlockhash))
        }
        
        private func encodeInstructions() throws -> Data {
            var compiledInstructions = [CompiledInstruction]()
            
            for instruction in programInstructions {
                
                let keysSize = instruction.keys.count
                
                var keyIndices = Data()
                for i in 0..<keysSize {
                    let index = try accountKeys.index(ofElementWithPublicKey: instruction.keys[i].publicKey)
                    keyIndices.append(UInt8(index))
                }
                
                let compiledInstruction = CompiledInstruction(
                    programIdIndex: UInt8(try accountKeys.index(ofElementWithPublicKey: instruction.programId)),
                    keyIndicesCount: [UInt8](Data.encodeLength(keysSize)),
                    keyIndices: [UInt8](keyIndices),
                    dataLength: [UInt8](Data.encodeLength(instruction.data.count)),
                    data: instruction.data
                )
                
                compiledInstructions.append(compiledInstruction)
            }
            
            let instructionsLength = encodeLength(compiledInstructions.count)
            
            return instructionsLength + compiledInstructions.reduce(Data(), {$0 + $1.serializedData})
        }
        
        private func encodeLength(_ length: Int) -> Data {
            Data.encodeLength(length)
        }
    }
}

extension SolanaSDK.Transaction.Message {
    // MARK: - Nested type
    public struct Header: Decodable {
        static let LENGTH = 3
        // TODO:
        var numRequiredSignatures: UInt8 = 0
        var numReadonlySignedAccounts: UInt8 = 0
        var numReadonlyUnsignedAccounts: UInt8 = 0
        
        var bytes: [UInt8] {
            [numRequiredSignatures, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }
    
    struct CompiledInstruction {
        let programIdIndex: UInt8
        let keyIndicesCount: [UInt8]
        let keyIndices: [UInt8]
        let dataLength: [UInt8]
        let data: [UInt8]
        
        var length: Int {
            1 + keyIndicesCount.count + keyIndices.count + dataLength.count + data.count
        }
        
        var serializedData: Data {
            Data([programIdIndex] + keyIndicesCount + keyIndices + dataLength + data)
        }
    }
}
