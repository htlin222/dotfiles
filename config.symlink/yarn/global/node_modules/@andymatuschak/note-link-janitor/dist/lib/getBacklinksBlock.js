"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const is = require("unist-util-is");
// Hacky type predicate here.
function isClosingMatterNode(node) {
    return "value" in node && node.value.startsWith("<!--");
}
function getBacklinksBlock(tree) {
    const existingBacklinksNodeIndex = tree.children.findIndex((node) => is(node, {
        type: "heading",
        depth: 2
    }) && is(node.children[0], { value: "Backlinks" }));
    if (existingBacklinksNodeIndex === -1) {
        const insertionPoint = tree.children.find(node => is(node, isClosingMatterNode)) || null;
        return {
            isPresent: false,
            insertionPoint
        };
    }
    else {
        const followingNode = tree.children
            .slice(existingBacklinksNodeIndex + 1)
            .find(node => is(node, [{ type: "heading" }, isClosingMatterNode])) ||
            null;
        return {
            isPresent: true,
            start: tree.children[existingBacklinksNodeIndex],
            until: followingNode
        };
    }
}
exports.default = getBacklinksBlock;
//# sourceMappingURL=getBacklinksBlock.js.map