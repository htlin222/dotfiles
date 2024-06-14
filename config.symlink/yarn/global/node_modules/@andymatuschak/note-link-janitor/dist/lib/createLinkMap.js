"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function createLinkMap(notes) {
    const linkMap = new Map();
    for (const note of notes) {
        for (const link of note.links) {
            const targetTitle = link.targetTitle;
            let backlinkEntryMap = linkMap.get(targetTitle);
            if (!backlinkEntryMap) {
                backlinkEntryMap = new Map();
                linkMap.set(targetTitle, backlinkEntryMap);
            }
            let contextList = backlinkEntryMap.get(note.title);
            if (!contextList) {
                contextList = [];
                backlinkEntryMap.set(note.title, contextList);
            }
            if (link.context) {
                contextList.push(link.context);
            }
        }
    }
    return linkMap;
}
exports.default = createLinkMap;
//# sourceMappingURL=createLinkMap.js.map