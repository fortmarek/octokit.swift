import Foundation
import RequestKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Model

public struct Asset: Codable {
    public let url: URL
    public let browserDownloadURL: URL
    public let id: Int
    public let nodeId: String
    public let name: String
    public let label: String
    public let state: String
    public let contentType: String
    public let size: Int
    public let downloadCount: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let uploader: User
    
    enum CodingKeys: String, CodingKey {
        case url, id, name, label, state, size, uploader

        case browserDownloadURL = "browser_download_url"
        case nodeId = "node_id"
        case contentType = "content_type"
        case downloadCount = "download_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: Request

public extension Octokit {
    /// Uploads asset to a new release.
    /// - Parameters:
    ///   - session: RequestKitURLSession, defaults to URLSession.shared()
    ///   - owner: The user or organization that owns the repositories.
    ///   - repo: The repository on which the release needs to be created.
    ///   - releaseId: Id of a release you want to upload the asset for
    ///   - binaryData: Data of file in binary format
    ///   - name: Name of the asset
    ///   - label: Alternate short description of the asset
    ///   - completion: Callback for the outcome of the uploaded asset
    @discardableResult
    func uploadAsset(
        _ session: RequestKitURLSession = URLSession.shared,
        owner: String,
        repository: String,
        releaseId: Int,
        binaryData: Data,
        name: String,
        label: String? = nil,
        completion: @escaping (_ response: Response<Asset>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = UploadAssetRouter.uploadAsset(
            configuration,
            owner,
            repository,
            releaseId,
            binaryData,
            name,
            label
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(session, decoder: decoder, expectedResultType: Asset.self) { issue, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let issue = issue {
                    completion(Response.success(issue))
                }
            }
        }
    }
}


// MARK: Router

enum UploadAssetRouter: JSONPostRouter {
    case uploadAsset(Configuration, String, String, Int, Data, String, String?)

    var configuration: Configuration {
        switch self {
        case let .uploadAsset(config, _, _, _, _, _, _):
            return config
        }
    }

    var method: HTTPMethod {
        return .POST
    }

    var encoding: HTTPEncoding {
        return .url
    }

    var params: [String: Any] {
        switch self {
        case let .uploadAsset(_, _, _, _, _, name, label):
            var params: [String: Any] = [
                "name": name,
            ]
            if let label = label {
                params["label"] = label
            }
            return params
        }
    }

    var path: String {
        switch self {
        case let .uploadAsset(_, owner, repo, releaseId, _, _, _):
            return "repos/\(owner)/\(repo)/releases/\(releaseId)/assets"
        }
    }
}
