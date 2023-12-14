// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchProblemByIdQuery: GraphQLQuery {
  public static let operationName: String = "FetchProblemById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchProblemById($id: ID!) { getProblemById(id: $id) { __typename ...ProblemFR } }"#,
      fragments: [LanguageFR.self, ProblemFR.self, TagFR.self]
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
        .fragment(ProblemFR.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var title: String { __data["title"] }
      public var context: String { __data["context"] }
      public var languages: [Language] { __data["languages"] }
      public var tags: [Tag] { __data["tags"] }
      public var accepted: Double { __data["accepted"] }
      public var submission: Double { __data["submission"] }
      public var maxCpuTime: String { __data["maxCpuTime"] }
      public var maxMemory: Double { __data["maxMemory"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var problemFR: ProblemFR { _toFragment() }
      }

      /// GetProblemById.Language
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

      /// GetProblemById.Tag
      ///
      /// Parent Type: `Tag`
      public struct Tag: CodestackAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Tag }

        public var id: Double { __data["id"] }
        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var tagFR: TagFR { _toFragment() }
        }
      }
    }
  }
}
