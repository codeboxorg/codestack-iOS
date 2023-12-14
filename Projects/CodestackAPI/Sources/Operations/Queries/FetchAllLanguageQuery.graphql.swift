// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchAllLanguageQuery: GraphQLQuery {
  public static let operationName: String = "FetchAllLanguage"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchAllLanguage { getAllLanguage { __typename ...LanguageFR } }"#,
      fragments: [LanguageFR.self]
    ))

  public init() {}

  public struct Data: CodestackAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getAllLanguage", [GetAllLanguage].self),
    ] }

    public var getAllLanguage: [GetAllLanguage] { __data["getAllLanguage"] }

    /// GetAllLanguage
    ///
    /// Parent Type: `Language`
    public struct GetAllLanguage: CodestackAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { CodestackAPI.Objects.Language }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(LanguageFR.self),
      ] }

      public var id: CodestackAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
      public var `extension`: String { __data["extension"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var languageFR: LanguageFR { _toFragment() }
      }
    }
  }
}
