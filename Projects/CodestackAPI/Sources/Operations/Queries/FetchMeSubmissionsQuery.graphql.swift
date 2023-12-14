// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchMeSubmissionsQuery: GraphQLQuery {
  public static let operationName: String = "FetchMeSubmissions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchMeSubmissions($username: String!) { matchMember(username: $username) { __typename submissions { __typename ...SubmissionFR } } }"#,
      fragments: [LanguageFR.self, ProblemIdentityFR.self, SubmissionFR.self]
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
        .field("submissions", [Submission].self),
      ] }

      public var submissions: [Submission] { __data["submissions"] }

      /// MatchMember.Submission
      ///
      /// Parent Type: `Submission`
      public struct Submission: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(SubmissionFR.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var language: Language { __data["language"] }
        public var member: SubmissionFR.Member { __data["member"] }
        public var memoryUsage: Double? { __data["memoryUsage"] }
        public var problem: Problem { __data["problem"] }
        public var sourceCode: String { __data["sourceCode"] }
        public var cpuTime: Double? { __data["cpuTime"] }
        public var statusCode: String? { __data["statusCode"] }
        public var updatedAt: CodestackAPI.DateTime { __data["updatedAt"] }
        public var createdAt: CodestackAPI.DateTime { __data["createdAt"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var submissionFR: SubmissionFR { _toFragment() }
        }

        /// MatchMember.Submission.Language
        ///
        /// Parent Type: `Language`
        public struct Language: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }

          public var id: CodestackAPI.ID { __data["id"] }
          public var name: String { __data["name"] }
          public var `extension`: String { __data["extension"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var languageFR: LanguageFR { _toFragment() }
          }
        }

        /// MatchMember.Submission.Problem
        ///
        /// Parent Type: `Problem`
        public struct Problem: CodestackAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }

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
}
