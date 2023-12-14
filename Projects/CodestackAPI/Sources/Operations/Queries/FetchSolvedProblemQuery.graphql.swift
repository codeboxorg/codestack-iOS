// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchSolvedProblemQuery: GraphQLQuery {
  public static let operationName: String = "FetchSolvedProblem"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchSolvedProblem($username: String!) { matchMember(username: $username) { __typename solvedProblems { __typename ...ProblemIdentityFR } } }"#,
      fragments: [ProblemIdentityFR.self]
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
        .field("solvedProblems", [SolvedProblem].self),
      ] }

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
          .fragment(ProblemIdentityFR.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var title: String { __data["title"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var problemIdentityFR: ProblemIdentityFR { _toFragment() }
        }
      }
    }
  }
}
