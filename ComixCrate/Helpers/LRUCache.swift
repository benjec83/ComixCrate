//
//  LRUCache.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

import Foundation
import SwiftUI
import CoreData

class LRUCache<Key: Hashable, Value> {
    private struct CacheNode {
        let key: Key
        var value: Value
    }

    private typealias Node = DoublyLinkedList<CacheNode>.Node

    private let capacity: Int
    private var cache: [Key: Node] = [:]
    private var list = DoublyLinkedList<CacheNode>()

    init(capacity: Int) {
        self.capacity = capacity
    }

    func get(_ key: Key) -> Value? {
        guard let node = cache[key] else { return nil }
        list.moveToFront(node)
        return node.data.value
    }

    func set(_ key: Key, value: Value) {
        if let node = cache[key] {
            node.data.value = value
            list.moveToFront(node)
        } else {
            let newNode = list.prepend(data: CacheNode(key: key, value: value))
            cache[key] = newNode

            if list.count > capacity {
                if let lastNode = list.removeLast() {
                    cache.removeValue(forKey: lastNode.data.key)
                }
            }
        }
    }
}

private class DoublyLinkedList<T> {
    class Node {
        var data: T
        var next: Node?
        var prev: Node?

        init(data: T) {
            self.data = data
        }
    }

    private(set) var count: Int = 0
    private var head: Node?
    private var tail: Node?

    func prepend(data: T) -> Node {
        let newNode = Node(data: data)
        if let head = head {
            newNode.next = head
            head.prev = newNode
        } else {
            tail = newNode
        }
        head = newNode
        count += 1
        return newNode
    }

    func moveToFront(_ node: Node) {
        guard node !== head else { return }
        remove(node)
        node.next = head
        node.prev = nil
        if let head = head {
            head.prev = node
        }
        self.head = node
        if tail == nil {
            tail = node
        }
    }

    func removeLast() -> Node? {
        guard let tail = self.tail else { return nil }
        remove(tail)
        return tail
    }

    private func remove(_ node: Node) {
        node.prev?.next = node.next
        node.next?.prev = node.prev
        if node === head {
            head = node.next
        }
        if node === tail {
            tail = node.prev
        }
        node.prev = nil
        node.next = nil
        count -= 1
    }
}

