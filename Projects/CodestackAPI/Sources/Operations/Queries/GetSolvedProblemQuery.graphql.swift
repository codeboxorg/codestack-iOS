// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSolvedProblemQuery: GraphQLQuery {
  public static let operationName: String = "GetSolvedProblem"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSolvedProblem($username: String!) { matchMember(username: $username) { __typename nickname email profileImage solvedProblems { __typename id title languages { __typename name extension } } } }"#
    ))

  public var username: String

  public init(username: String) {
    self.username = username
  }

  public var __variables: Variables? { ["username": username] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("matchMember", MatchMember.self, arguments: ["username": .variable("username")]),
    ] }

    public var matchMember: MatchMember { __data["matchMember"] }

    /// MatchMember
    ///
    /// Parent Type: `Member`
    public struct MatchMember: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nickname", String.self),
        .field("email", String?.self),
        .field("profileImage", String?.self),
        .field("solvedProblems", [SolvedProblem].self),
      ] }

      public var nickname: String { __data["nickname"] }
      public var email: String? { __data["email"] }
      public var profileImage: String? { __data["profileImage"] }
      public var solvedProblems: [SolvedProblem] { __data["solvedProblems"] }

      /// MatchMember.SolvedProblem
      ///
      /// Parent Type: `Problem`
      public struct SolvedProblem: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("title", String.self),
          .field("languages", [Language].self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }
        public var languages: [Language] { __data["languages"] }

        /// MatchMember.SolvedProblem.Language
        ///
        /// Parent Type: `Language`
        public struct Language: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("extension", String.self),
          ] }

          public var name: String { __data["name"] }
          public var `extension`: String { __data["extension"] }
        }
      }
    }
  }
}
