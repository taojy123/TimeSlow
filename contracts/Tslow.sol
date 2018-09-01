pragma solidity ^0.4.24;


contract Tslow {

    struct Event {
        uint id;
        address owner;
        string title;
        string content;
        uint ts;
    }

    struct Comment {
        uint id;
        uint eventId;
        address owner;
        string content;
        uint ts;
    }

    uint public MAX_LEVEL = 100;
    Event[] public events;
    Comment[] public comments;

    mapping (address => uint) public eventCountOf;
    mapping (address => uint) public commentCountOf;
    mapping (address => string) public nicknameOf;

    event EventPosted(uint id, address indexed owner, string title, string content, uint ts);
    event CommentPosted(uint eventId, address indexed owner, string content, uint ts);

    constructor() public {
    }

    function pointsOf(address owner) public view returns (uint) {
        return eventCountOf[owner] * 10 + commentCountOf[owner];
    }

    function levelOf(address owner) public view returns (uint) {
        //  0 -  9 -> level 1
        // 10 - 13 -> level 2
        // 14 - 19 -> level 3
        // 20 - 27 -> level 4
        // ...
        uint ownerpoints = pointsOf(owner);
        uint target = 8;
        for(uint i = 1; i < MAX_LEVEL; i++) {
            target = target + i * 2;
            if (target > ownerpoints) {
                return i;
            }
        }
        return MAX_LEVEL;
    }
    function myPoints() public view returns (uint) {
        return pointsOf(msg.sender);
    }

    function myLevel() public view returns (uint) {
        return levelOf(msg.sender);
    }

    function setNickname(string nickname) public {
        nicknameOf[msg.sender] = nickname;
    }

    function nicknameOf(address owner) public view returns (string) {
        return nicknameOf[owner];
    }

    function myNickname() public view returns (string) {
        return nicknameOf[msg.sender];
    }

    function postEvent(string title, string content) public {
        assert(keccak256(title) != keccak256(""));
        assert(keccak256(content) != keccak256(""));
        uint id = events.length;
        address owner = msg.sender;
        events.push(Event(id, owner, title, content, now));
        eventCountOf[msg.sender] ++;
        emit EventPosted(id, owner, title, content, now);
    }

    function postComment(uint eventId, string content) public {
        assert(keccak256(content) != keccak256(""));
        uint id = comments.length;
        address owner = msg.sender;
        comments.push(Comment(id, eventId, owner, content, now));
        commentCountOf[msg.sender] ++;
        emit CommentPosted(eventId, owner, content, now);
    }

    function getEventIds() public view returns (uint[]) {
        uint[] memory rs = new uint[](events.length);
        for(uint i = 0; i < events.length; i++) {
            rs[i] = events[i].id;
        }
        return rs;
    }

    function getCommentIdsByEvent(uint eventId) public view returns (uint[]) {
        uint counter = 0;
        uint i = 0;
        for(i = 0; i < comments.length; i++) {
            if (comments[i].eventId == eventId) {
                counter++;
            }
        }
        uint[] memory rs = new uint[](counter);
        counter = 0;
        for(i = 0; i < comments.length; i++) {
            if (comments[i].eventId == eventId) {
                rs[counter] = comments[i].id;
                counter++;
            }
        }
        return rs;
    }

}
