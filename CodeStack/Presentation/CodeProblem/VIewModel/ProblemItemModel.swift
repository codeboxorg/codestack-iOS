//
//  ProblemModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import Foundation

var contextExample  =
"""
   <body><h1>문제</h1>
         <p>Hello, World를 출력하세요</p>
         <h1>입력</h1>
         <p>없음</p>
         <h1>출력</h1>
         <p>Hello, World를 출력하세요</p>
         <section class="sample-body">
           <div class="sample-item">
             <div>
               <div class="sample-item-header">
                 <div>예제입력 1</div>
                 <button class="copy-button" data-clipboard-target="#sample-input-1">
                   복사
                 </button>
               </div>
               <div>
                 <pre class="sample-data" id="sample-input-1">없음</pre>
               </div>
             </div>
             <div>
               <div class="sample-item-header">
                 <div>예제출력 1</div>
                 <button class="copy-button" data-clipboard-target="#sample-output-1">
                   복사
                 </button>
               </div>
               <div>
                 <pre class="sample-data" id="sample-output-1">Hello, World!</pre>
               </div>
             </div>
           </div>
         </section></body>
   """
struct ProblemListItemModel: Equatable{
    
    var problemNumber: String
    var problemTitle: String
    var submitCount: Int
    var correctAnswer: Int
    var correctRate: Double
    var contenxt: String?
    var tags: [Tag]
    var language: [Language]
    
    init(problemNumber: String, problemTitle: String, submitCount: Int, correctAnswer: Int, correctRate: Double,tags: [Tag] = [],languages: [Language] = []) {
        self.problemNumber = problemNumber
        self.problemTitle = problemTitle
        self.submitCount = submitCount
        self.correctAnswer = correctAnswer
        self.correctRate = correctRate
        
        self.tags = []
        self.language =
        ["C", "JAVA" , "C++", "Node.js", "Swift", "Kot", "Go", "Python", "javascript"]
            .map{ name in Language(id: "1", name: name, _extension: "ㅋ")}
        
        self.contenxt = contextExample
        
    }
    
    init(problemNumber: String,
         problemTitle: String,
         submitCount: Int,
         correctAnswer: Int,
         correctRate: Double,
         contenxt: String,
         tags: [Tag] = [],
         languages: [Language] = [])
    {
        self.problemNumber = problemNumber
        self.problemTitle = problemTitle
        self.submitCount = submitCount
        self.correctAnswer = correctAnswer
        self.correctRate = correctRate
        self.contenxt = contenxt
        self.tags = tags
        self.language = languages
    }
    
    init(){
        self.problemNumber = ""
        self.problemTitle = ""
        self.submitCount = 0
        self.correctAnswer = 0
        self.correctRate = 0
        self.tags = []
        self.language = []
    }
}

struct LanguageList{
    var languages: String
    var _extension: String
}

