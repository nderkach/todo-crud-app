//
//  IdeaManager.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/8/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Foundation
import Siesta

let IdeaManager = _IdeaManager()

class _IdeaManager {

    var total: Int {
        return ideas.count
    }

    private var ideas: [Idea] = [] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("ideasChanged"), object: nil)
        }
    }

    private func addIdea(_ idea: Idea, atIndex index: Int, onFailure: @escaping (String) -> Void, onSuccess: @escaping (Int) -> Void) -> Void {
        CMXAPI.addIdea(idea).onSuccess { entity in
            if let createdIdea: Idea = entity.typedContent() {
                self.ideas.insert(createdIdea, at: index)
                onSuccess(index)
            }
            }.onFailure { error in
                onFailure(error.userMessage)
        }
    }

    func addIdea(_ idea: Idea, onFailure: @escaping (String) -> Void, onSuccess: @escaping (Int) -> Void) -> Void {
        if let index = ideas.index(where: { $0.averageScore < idea.averageScore }) {
            addIdea(idea, atIndex: index, onFailure: onFailure, onSuccess: onSuccess)
        } else {
            addIdea(idea, atIndex: ideas.count, onFailure: onFailure, onSuccess: onSuccess)
        }
    }

    func removeIdea(atIndex index: Int) {
        let idea = ideas[index]
        ideas.remove(at: index)
        CMXAPI.removeIdea(idea).onSuccess { _ in }
    }

    func idea(atIndex index: Int) -> Idea {
        return ideas[index]
    }

    func updateIdea(withIdea idea: Idea, oldIndex: Int, newIndex: Int, onSuccess: @escaping (Int, Int) -> Void) {
        CMXAPI.updateIdea(idea).onSuccess { _ in
            self.ideas.insert(idea, at: newIndex)
            onSuccess(oldIndex, newIndex)
        }
    }

    func updateIdea(withIdea idea: Idea, onSuccess: @escaping (Int, Int) -> Void) {
        if let oldIndex = ideas.index(where: { $0.id == idea.id }) {
            ideas.remove(at: oldIndex)

            if let newIndex = ideas.index(where: { $0.averageScore < idea.averageScore }) {
                updateIdea(withIdea: idea, oldIndex: oldIndex, newIndex: newIndex, onSuccess: onSuccess)
            } else {
                updateIdea(withIdea: idea, oldIndex: oldIndex, newIndex: ideas.count, onSuccess: onSuccess)
            }
        }
    }

    func fetchIdeas() {
        CMXAPI.ideas().addObserver(self).load()
    }
}

// MARK: - ResourceObserver

extension _IdeaManager: ResourceObserver {
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        ideas = resource.typedContent() ?? []
        NotificationCenter.default.post(name: Notification.Name("ideasReloaded"), object: nil)
    }
}
