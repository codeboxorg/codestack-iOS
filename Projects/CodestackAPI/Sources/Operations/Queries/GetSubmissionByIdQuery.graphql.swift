// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSubmissionByIdQuery: GraphQLQuery {
  public static let operationName: String = "GetSubmissionById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSubmissionById($id: ID!) { getSubmissionById(id: $id) { __typename cpuTime id member { __typename nickname username } } }"#
    ))

  public var id: ID

  public init(id: ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getSubmissionById", GetSubmissionById.self, arguments: ["id": .variable("id")]),
    ] }

    public var getSubmissionById: GetSubmissionById { __data["getSubmissionById"] }

    /// GetSubmissionById
    ///
    /// Parent Type: `Submission`
    public struct GetSubmissionById: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Submission }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("cpuTime", Double?.self),
        .field("id", CodestackAPI.ID.self),
        .field("member", Member.self),
      ] }

      public var cpuTime: Double? { __data["cpuTime"] }
      public var id: CodestackAPI.ID { __data["id"] }
      public var member: Member { __data["member"] }

      /// GetSubmissionById.Member
      ///
      /// Parent Type: `Member`
      public struct Member: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Member }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nickname", String.self),
          .field("username", CodestackAPI.ID.self),
        ] }

        public var nickname: String { __data["nickname"] }
        public var username: CodestackAPI.ID { __data["username"] }
      }
    }
  }
}
