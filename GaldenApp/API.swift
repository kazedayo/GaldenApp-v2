//  This file was automatically generated and should not be edited.

import Apollo

public enum ReplySorting: RawRepresentable, Equatable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case dateAsc
  case dateDesc
  case ratingTop
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "date_asc": self = .dateAsc
      case "date_desc": self = .dateDesc
      case "rating_top": self = .ratingTop
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .dateAsc: return "date_asc"
      case .dateDesc: return "date_desc"
      case .ratingTop: return "rating_top"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ReplySorting, rhs: ReplySorting) -> Bool {
    switch (lhs, rhs) {
      case (.dateAsc, .dateAsc): return true
      case (.dateDesc, .dateDesc): return true
      case (.ratingTop, .ratingTop): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum UserGender: RawRepresentable, Equatable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case m
  case f
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "M": self = .m
      case "F": self = .f
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .m: return "M"
      case .f: return "F"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: UserGender, rhs: UserGender) -> Bool {
    switch (lhs, rhs) {
      case (.m, .m): return true
      case (.f, .f): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public final class GetChannelListQuery: GraphQLQuery {
  public let operationDefinition =
    "query GetChannelList {\n  channels {\n    __typename\n    ...ChannelDetails\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(ChannelDetails.fragmentDefinition).appending(TagDetails.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("channels", type: .nonNull(.list(.nonNull(.object(Channel.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(channels: [Channel]) {
      self.init(unsafeResultMap: ["__typename": "Query", "channels": channels.map { (value: Channel) -> ResultMap in value.resultMap }])
    }

    public var channels: [Channel] {
      get {
        return (resultMap["channels"] as! [ResultMap]).map { (value: ResultMap) -> Channel in Channel(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Channel) -> ResultMap in value.resultMap }, forKey: "channels")
      }
    }

    public struct Channel: GraphQLSelectionSet {
      public static let possibleTypes = ["Channel"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ChannelDetails.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var channelDetails: ChannelDetails {
          get {
            return ChannelDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetThreadsQuery: GraphQLQuery {
  public let operationDefinition =
    "query GetThreads($id: [String!]!, $page: Int!) {\n  threads(tagIds: $id, page: $page) {\n    __typename\n    ...ThreadListDetails\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(ThreadListDetails.fragmentDefinition).appending(TagDetails.fragmentDefinition) }

  public var id: [String]
  public var page: Int

  public init(id: [String], page: Int) {
    self.id = id
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["id": id, "page": page]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("threads", arguments: ["tagIds": GraphQLVariable("id"), "page": GraphQLVariable("page")], type: .nonNull(.list(.nonNull(.object(Thread.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(threads: [Thread]) {
      self.init(unsafeResultMap: ["__typename": "Query", "threads": threads.map { (value: Thread) -> ResultMap in value.resultMap }])
    }

    public var threads: [Thread] {
      get {
        return (resultMap["threads"] as! [ResultMap]).map { (value: ResultMap) -> Thread in Thread(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Thread) -> ResultMap in value.resultMap }, forKey: "threads")
      }
    }

    public struct Thread: GraphQLSelectionSet {
      public static let possibleTypes = ["Thread"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ThreadListDetails.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var threadListDetails: ThreadListDetails {
          get {
            return ThreadListDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class GetThreadContentQuery: GraphQLQuery {
  public let operationDefinition =
    "query GetThreadContent($id: Int!, $sorting: ReplySorting!, $page: Int!) {\n  thread(id: $id, sorting: $sorting, page: $page) {\n    __typename\n    id\n    title\n    totalReplies\n    replies {\n      __typename\n      ...CommentsRecursive\n    }\n    tags {\n      __typename\n      name\n      color\n    }\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(CommentsRecursive.fragmentDefinition).appending(CommentFields.fragmentDefinition) }

  public var id: Int
  public var sorting: ReplySorting
  public var page: Int

  public init(id: Int, sorting: ReplySorting, page: Int) {
    self.id = id
    self.sorting = sorting
    self.page = page
  }

  public var variables: GraphQLMap? {
    return ["id": id, "sorting": sorting, "page": page]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("thread", arguments: ["id": GraphQLVariable("id"), "sorting": GraphQLVariable("sorting"), "page": GraphQLVariable("page")], type: .object(Thread.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(thread: Thread? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "thread": thread.flatMap { (value: Thread) -> ResultMap in value.resultMap }])
    }

    public var thread: Thread? {
      get {
        return (resultMap["thread"] as? ResultMap).flatMap { Thread(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "thread")
      }
    }

    public struct Thread: GraphQLSelectionSet {
      public static let possibleTypes = ["Thread"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(Int.self))),
        GraphQLField("title", type: .nonNull(.scalar(String.self))),
        GraphQLField("totalReplies", type: .nonNull(.scalar(Int.self))),
        GraphQLField("replies", type: .nonNull(.list(.nonNull(.object(Reply.selections))))),
        GraphQLField("tags", type: .nonNull(.list(.nonNull(.object(Tag.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: Int, title: String, totalReplies: Int, replies: [Reply], tags: [Tag]) {
        self.init(unsafeResultMap: ["__typename": "Thread", "id": id, "title": title, "totalReplies": totalReplies, "replies": replies.map { (value: Reply) -> ResultMap in value.resultMap }, "tags": tags.map { (value: Tag) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: Int {
        get {
          return resultMap["id"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public var totalReplies: Int {
        get {
          return resultMap["totalReplies"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "totalReplies")
        }
      }

      public var replies: [Reply] {
        get {
          return (resultMap["replies"] as! [ResultMap]).map { (value: ResultMap) -> Reply in Reply(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Reply) -> ResultMap in value.resultMap }, forKey: "replies")
        }
      }

      public var tags: [Tag] {
        get {
          return (resultMap["tags"] as! [ResultMap]).map { (value: ResultMap) -> Tag in Tag(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Tag) -> ResultMap in value.resultMap }, forKey: "tags")
        }
      }

      public struct Reply: GraphQLSelectionSet {
        public static let possibleTypes = ["Reply"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CommentsRecursive.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var commentsRecursive: CommentsRecursive {
            get {
              return CommentsRecursive(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Tag: GraphQLSelectionSet {
        public static let possibleTypes = ["Tag"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("color", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, color: String) {
          self.init(unsafeResultMap: ["__typename": "Tag", "name": name, "color": color])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var color: String {
          get {
            return resultMap["color"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "color")
          }
        }
      }
    }
  }
}

public struct ChannelDetails: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment ChannelDetails on Channel {\n  __typename\n  id\n  name\n  tags {\n    __typename\n    ...TagDetails\n  }\n}"

  public static let possibleTypes = ["Channel"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("tags", type: .nonNull(.list(.nonNull(.object(Tag.selections))))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, name: String, tags: [Tag]) {
    self.init(unsafeResultMap: ["__typename": "Channel", "id": id, "name": name, "tags": tags.map { (value: Tag) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  public var tags: [Tag] {
    get {
      return (resultMap["tags"] as! [ResultMap]).map { (value: ResultMap) -> Tag in Tag(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Tag) -> ResultMap in value.resultMap }, forKey: "tags")
    }
  }

  public struct Tag: GraphQLSelectionSet {
    public static let possibleTypes = ["Tag"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(TagDetails.self),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, name: String, color: String) {
      self.init(unsafeResultMap: ["__typename": "Tag", "id": id, "name": name, "color": color])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var tagDetails: TagDetails {
        get {
          return TagDetails(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct TagDetails: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment TagDetails on Tag {\n  __typename\n  id\n  name\n  color\n}"

  public static let possibleTypes = ["Tag"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("color", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, name: String, color: String) {
    self.init(unsafeResultMap: ["__typename": "Tag", "id": id, "name": name, "color": color])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  public var color: String {
    get {
      return resultMap["color"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "color")
    }
  }
}

public struct ThreadListDetails: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment ThreadListDetails on Thread {\n  __typename\n  id\n  title\n  replies {\n    __typename\n    authorNickname\n    date\n  }\n  totalReplies\n  tags {\n    __typename\n    ...TagDetails\n  }\n}"

  public static let possibleTypes = ["Thread"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(Int.self))),
    GraphQLField("title", type: .nonNull(.scalar(String.self))),
    GraphQLField("replies", type: .nonNull(.list(.nonNull(.object(Reply.selections))))),
    GraphQLField("totalReplies", type: .nonNull(.scalar(Int.self))),
    GraphQLField("tags", type: .nonNull(.list(.nonNull(.object(Tag.selections))))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: Int, title: String, replies: [Reply], totalReplies: Int, tags: [Tag]) {
    self.init(unsafeResultMap: ["__typename": "Thread", "id": id, "title": title, "replies": replies.map { (value: Reply) -> ResultMap in value.resultMap }, "totalReplies": totalReplies, "tags": tags.map { (value: Tag) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: Int {
    get {
      return resultMap["id"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return resultMap["title"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  public var replies: [Reply] {
    get {
      return (resultMap["replies"] as! [ResultMap]).map { (value: ResultMap) -> Reply in Reply(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Reply) -> ResultMap in value.resultMap }, forKey: "replies")
    }
  }

  public var totalReplies: Int {
    get {
      return resultMap["totalReplies"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "totalReplies")
    }
  }

  public var tags: [Tag] {
    get {
      return (resultMap["tags"] as! [ResultMap]).map { (value: ResultMap) -> Tag in Tag(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Tag) -> ResultMap in value.resultMap }, forKey: "tags")
    }
  }

  public struct Reply: GraphQLSelectionSet {
    public static let possibleTypes = ["Reply"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("authorNickname", type: .nonNull(.scalar(String.self))),
      GraphQLField("date", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(authorNickname: String, date: String) {
      self.init(unsafeResultMap: ["__typename": "Reply", "authorNickname": authorNickname, "date": date])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var authorNickname: String {
      get {
        return resultMap["authorNickname"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "authorNickname")
      }
    }

    public var date: String {
      get {
        return resultMap["date"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "date")
      }
    }
  }

  public struct Tag: GraphQLSelectionSet {
    public static let possibleTypes = ["Tag"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(TagDetails.self),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, name: String, color: String) {
      self.init(unsafeResultMap: ["__typename": "Tag", "id": id, "name": name, "color": color])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var tagDetails: TagDetails {
        get {
          return TagDetails(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct CommentsRecursive: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment CommentsRecursive on Reply {\n  __typename\n  ...CommentFields\n  parent {\n    __typename\n    ...CommentFields\n    parent {\n      __typename\n      ...CommentFields\n      parent {\n        __typename\n        ...CommentFields\n        parent {\n          __typename\n          ...CommentFields\n        }\n      }\n    }\n  }\n}"

  public static let possibleTypes = ["Reply"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLFragmentSpread(CommentFields.self),
    GraphQLField("parent", type: .object(Parent.selections)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var parent: Parent? {
    get {
      return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "parent")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var commentFields: CommentFields {
      get {
        return CommentFields(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }

  public struct Parent: GraphQLSelectionSet {
    public static let possibleTypes = ["Reply"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(CommentFields.self),
      GraphQLField("parent", type: .object(Parent.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var parent: Parent? {
      get {
        return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "parent")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var commentFields: CommentFields {
        get {
          return CommentFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct Parent: GraphQLSelectionSet {
      public static let possibleTypes = ["Reply"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CommentFields.self),
        GraphQLField("parent", type: .object(Parent.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var parent: Parent? {
        get {
          return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "parent")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var commentFields: CommentFields {
          get {
            return CommentFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Parent: GraphQLSelectionSet {
        public static let possibleTypes = ["Reply"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CommentFields.self),
          GraphQLField("parent", type: .object(Parent.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var parent: Parent? {
          get {
            return (resultMap["parent"] as? ResultMap).flatMap { Parent(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "parent")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var commentFields: CommentFields {
            get {
              return CommentFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Parent: GraphQLSelectionSet {
          public static let possibleTypes = ["Reply"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(CommentFields.self),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var commentFields: CommentFields {
              get {
                return CommentFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }
}

public struct CommentFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment CommentFields on Reply {\n  __typename\n  id\n  floor\n  author {\n    __typename\n    id\n    avatar\n    nickname\n    gender\n    groups {\n      __typename\n      id\n      name\n    }\n  }\n  authorNickname\n  parentId\n  content\n  date\n}"

  public static let possibleTypes = ["Reply"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(String.self))),
    GraphQLField("floor", type: .nonNull(.scalar(Int.self))),
    GraphQLField("author", type: .nonNull(.object(Author.selections))),
    GraphQLField("authorNickname", type: .nonNull(.scalar(String.self))),
    GraphQLField("parentId", type: .scalar(String.self)),
    GraphQLField("content", type: .nonNull(.scalar(String.self))),
    GraphQLField("date", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, floor: Int, author: Author, authorNickname: String, parentId: String? = nil, content: String, date: String) {
    self.init(unsafeResultMap: ["__typename": "Reply", "id": id, "floor": floor, "author": author.resultMap, "authorNickname": authorNickname, "parentId": parentId, "content": content, "date": date])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var floor: Int {
    get {
      return resultMap["floor"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "floor")
    }
  }

  public var author: Author {
    get {
      return Author(unsafeResultMap: resultMap["author"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "author")
    }
  }

  public var authorNickname: String {
    get {
      return resultMap["authorNickname"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "authorNickname")
    }
  }

  public var parentId: String? {
    get {
      return resultMap["parentId"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "parentId")
    }
  }

  public var content: String {
    get {
      return resultMap["content"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }

  public var date: String {
    get {
      return resultMap["date"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "date")
    }
  }

  public struct Author: GraphQLSelectionSet {
    public static let possibleTypes = ["User"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("avatar", type: .scalar(String.self)),
      GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
      GraphQLField("gender", type: .nonNull(.scalar(UserGender.self))),
      GraphQLField("groups", type: .nonNull(.list(.nonNull(.object(Group.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: String, avatar: String? = nil, nickname: String, gender: UserGender, groups: [Group]) {
      self.init(unsafeResultMap: ["__typename": "User", "id": id, "avatar": avatar, "nickname": nickname, "gender": gender, "groups": groups.map { (value: Group) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: String {
      get {
        return resultMap["id"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    public var avatar: String? {
      get {
        return resultMap["avatar"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "avatar")
      }
    }

    public var nickname: String {
      get {
        return resultMap["nickname"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "nickname")
      }
    }

    public var gender: UserGender {
      get {
        return resultMap["gender"]! as! UserGender
      }
      set {
        resultMap.updateValue(newValue, forKey: "gender")
      }
    }

    public var groups: [Group] {
      get {
        return (resultMap["groups"] as! [ResultMap]).map { (value: ResultMap) -> Group in Group(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Group) -> ResultMap in value.resultMap }, forKey: "groups")
      }
    }

    public struct Group: GraphQLSelectionSet {
      public static let possibleTypes = ["Group"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: Int, name: String) {
        self.init(unsafeResultMap: ["__typename": "Group", "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: Int {
        get {
          return resultMap["id"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}