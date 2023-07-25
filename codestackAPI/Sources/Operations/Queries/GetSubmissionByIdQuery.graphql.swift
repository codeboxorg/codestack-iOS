// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSubmissionByIdQuery: GraphQLQuery {
  public static let operationName: String = "GetSubmissionById"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query GetSubmissionById($id: Float!) {
        getSubmissionById(id: $id) {
          __typename
          id
          memberId
          language {
            __typename
            id
          }
        }
      }
      """#
    ))

  public var id: Double

  public init(id: Double) {
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
        .field("id", CodestackAPI.ID.self),
        .field("memberId", Double.self),
        .field("language", Language.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var memberId: Double { __data["memberId"] }
      public var language: Language { __data["language"] }

      /// GetSubmissionById.Language
      ///
      /// Parent Type: `Language`
      public struct Language: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
      }
    }
  }
}
