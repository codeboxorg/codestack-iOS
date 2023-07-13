// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == CodestackAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == CodestackAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == CodestackAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == CodestackAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return CodestackAPI.Objects.Query
    case "ProblemPagedResult": return CodestackAPI.Objects.ProblemPagedResult
    case "Problem": return CodestackAPI.Objects.Problem
    case "PageInfo": return CodestackAPI.Objects.PageInfo
    case "Tag": return CodestackAPI.Objects.Tag
    case "Language": return CodestackAPI.Objects.Language
    case "Mutation": return CodestackAPI.Objects.Mutation
    case "Submission": return CodestackAPI.Objects.Submission
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
