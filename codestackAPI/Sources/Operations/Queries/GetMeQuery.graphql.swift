// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetMeQuery: GraphQLQuery {
  public static let operationName: String = "GetMe"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetMe { getMe { __typename email nickname profileImage solvedProblems { __typename id } username } }"#
    ))

  public init() {}

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getMe", GetMe.self),
    ] }

    public var getMe: GetMe { __data["getMe"] }

    /// GetMe
    ///
    /// Parent Type: `Member`
    public struct GetMe: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("email", String?.self),
        .field("nickname", String.self),
        .field("profileImage", String?.self),
        .field("solvedProblems", [SolvedProblem].self),
        .field("username", CodestackAPI.ID.self),
      ] }

      public var email: String? { __data["email"] }
      public var nickname: String { __data["nickname"] }
      public var profileImage: String? { __data["profileImage"] }
      public var solvedProblems: [SolvedProblem] { __data["solvedProblems"] }
      public var username: CodestackAPI.ID { __data["username"] }

      /// GetMe.SolvedProblem
      ///
      /// Parent Type: `Problem`
      public struct SolvedProblem: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
      }
    }
  }
}
