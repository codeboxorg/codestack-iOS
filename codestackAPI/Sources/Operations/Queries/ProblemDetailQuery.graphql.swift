// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ProblemDetailQuery: GraphQLQuery {
  public static let operationName: String = "ProblemDetail"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query ProblemDetail($id: ID) {
        problem(id: $id) {
          __typename
          id
          maxCpuTime
          maxMemory
          title
          context
          submission
          accepted
          tags {
            __typename
            id
            name
          }
          languages {
            __typename
            id
            name
            extension
          }
        }
      }
      """#
    ))

  public var id: GraphQLNullable<ID>

  public init(id: GraphQLNullable<ID>) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("problem", Problem?.self, arguments: ["id": .variable("id")]),
    ] }

    public var problem: Problem? { __data["problem"] }

    /// Problem
    ///
    /// Parent Type: `Problem`
    public struct Problem: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Problem }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", Int?.self),
        .field("maxCpuTime", Int?.self),
        .field("maxMemory", Int?.self),
        .field("title", String?.self),
        .field("context", String?.self),
        .field("submission", Int?.self),
        .field("accepted", Int?.self),
        .field("tags", [Tag?]?.self),
        .field("languages", [Language?]?.self),
      ] }

      public var id: Int? { __data["id"] }
      public var maxCpuTime: Int? { __data["maxCpuTime"] }
      public var maxMemory: Int? { __data["maxMemory"] }
      public var title: String? { __data["title"] }
      public var context: String? { __data["context"] }
      public var submission: Int? { __data["submission"] }
      public var accepted: Int? { __data["accepted"] }
      public var tags: [Tag?]? { __data["tags"] }
      public var languages: [Language?]? { __data["languages"] }

      /// Problem.Tag
      ///
      /// Parent Type: `Tag`
      public struct Tag: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", Int?.self),
          .field("name", String?.self),
        ] }

        public var id: Int? { __data["id"] }
        public var name: String? { __data["name"] }
      }

      /// Problem.Language
      ///
      /// Parent Type: `Language`
      public struct Language: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", Int?.self),
          .field("name", String?.self),
          .field("extension", String?.self),
        ] }

        public var id: Int? { __data["id"] }
        public var name: String? { __data["name"] }
        public var `extension`: String? { __data["extension"] }
      }
    }
  }
}
