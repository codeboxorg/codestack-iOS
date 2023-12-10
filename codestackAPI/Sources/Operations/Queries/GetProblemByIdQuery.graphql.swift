// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetProblemByIdQuery: GraphQLQuery {
  public static let operationName: String = "GetProblemById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetProblemById($id: ID!) { getProblemById(id: $id) { __typename accepted context id languages { __typename id name extension } maxCpuTime maxMemory submission tags { __typename id name } title } }"#
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
      .field("getProblemById", GetProblemById.self, arguments: ["id": .variable("id")]),
    ] }

    public var getProblemById: GetProblemById { __data["getProblemById"] }

    /// GetProblemById
    ///
    /// Parent Type: `Problem`
    public struct GetProblemById: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("accepted", Double.self),
        .field("context", String.self),
        .field("id", CodestackAPI.ID.self),
        .field("languages", [Language].self),
        .field("maxCpuTime", String.self),
        .field("maxMemory", Double.self),
        .field("submission", Double.self),
        .field("tags", [Tag].self),
        .field("title", String.self),
      ] }

      public var accepted: Double { __data["accepted"] }
      public var context: String { __data["context"] }
      public var id: CodestackAPI.ID { __data["id"] }
      public var languages: [Language] { __data["languages"] }
      public var maxCpuTime: String { __data["maxCpuTime"] }
      public var maxMemory: Double { __data["maxMemory"] }
      public var submission: Double { __data["submission"] }
      public var tags: [Tag] { __data["tags"] }
      public var title: String { __data["title"] }

      /// GetProblemById.Language
      ///
      /// Parent Type: `Language`
      public struct Language: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", CodestackAPI.ID.self),
          .field("name", String.self),
          .field("extension", String.self),
        ] }

        public var id: CodestackAPI.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var `extension`: String { __data["extension"] }
      }

      /// GetProblemById.Tag
      ///
      /// Parent Type: `Tag`
      public struct Tag: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", Double.self),
          .field("name", String.self),
        ] }

        public var id: Double { __data["id"] }
        public var name: String { __data["name"] }
      }
    }
  }
}
