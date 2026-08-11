//
//  SecretGardenApp.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 7/8/26.
//

import SwiftUI
import CoreModels
import CoreNetworking
import CoreStorage
import DesignSystem
import CoreArchitecture
import Repositories
import FactoryKit

@main
struct SecretGardenApp: App {
    var body: some Scene {
        WindowGroup {
            DIVerificationView()
        }
    }
}

private struct DIVerificationView: View {
    @Injected(\.seriesRepository) private var seriesRepository
    @Injected(\.seriesRepository) private var seriesRepositoryAgain

    @State private var resultText = "Chưa gọi"

    private var isSingletonWorking: Bool {
        (seriesRepository as AnyObject) === (seriesRepositoryAgain as AnyObject)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Environment: \(AppConfig.environment.rawValue)")
            Text("Repository type: \(String(describing: type(of: seriesRepository)))")
            Text("Singleton hoạt động đúng: \(isSingletonWorking ? "co" : "khong")")
            Text(resultText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Goi thu fetchSeriesDetail") {
                Task {
                    do {
                        _ = try await seriesRepository.fetchSeriesDetail(id: "test")
                        resultText = "Thanh cong (KHONG mong doi o giai doan nay)"
                    } catch let error as AppError {
                        resultText = "Nhan dung AppError: \(error.localizedDescription)"
                    } catch {
                        resultText = "Sai kieu loi, khong mong doi: \(error)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
