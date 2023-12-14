// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateNickNameMutation: GraphQLMutation {
  public static let operationName: String = "UpdateNickName"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateNickName($nickname: String!) { updateNickname(nickname: $nickname) { __typename ...MemberFR } }"#,
      fragments: [MemberFR.self, ProblemIdentityFR.self]
    ))

  public var nickname: String

  public init(nickname: String) {
    self.nickname = nickname
  }

  public var __variables: Variables? { ["nickname": nickname] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateNickname", UpdateNickname.self, arguments: ["nickname": .variable("nickname")]),
    ] }

    public var updateNickname: UpdateNickname { __data["updateNickname"] }

    /// UpdateNickname
    ///
    /// Parent Type: `Member`
    public struct UpdateNickname: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MemberFR.self),
      ] }

      public var email: String? { __data["email"] }
      public var nickname: String { __data["nickname"] }
      public var username: CodestackAPI.ID { __data["username"] }
      public var profileImage: String? { __data["profileImage"] }
      public var solvedProblems: [SolvedProblem] { __data["solvedProblems"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var memberFR: MemberFR { _toFragment() }
      }

      /// UpdateNickname.SolvedProblem
      ///
      /// Parent Type: `Problem`
      public struct SolvedProblem: CodestackAPI.SelectionSet {
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
