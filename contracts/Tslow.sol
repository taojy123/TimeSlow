pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


contract Tslow {

    struct Event {
        uint id;
        address owner;
        string title;
        string content;
        uint ts;
    }

    struct Comment {
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
        uint ownerpoints = pointsOf(owner);
        uint target = 10;
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

    function mylevel() public view returns (uint) {
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
        uint id = events.length;
        address owner = msg.sender;
        uint ts = now;
        Event memory _event = Event(id, owner, title, content, ts);
        events.push(_event);
        eventCountOf[msg.sender] ++;
        emit EventPosted(id, owner, title, content, ts);
    }

    function postComment(uint eventId, string content) public {
        address owner = msg.sender;
        uint ts = now;
        Comment memory comment = Comment(eventId, owner, content, ts);
        comments.push(comment);
        commentCountOf[msg.sender] ++;
        emit CommentPosted(eventId, owner, content, ts);
    }

    function getEvents() public view returns (Event[]) {
        return events;
    }

    function getCommentByEvent(uint eventId) public view returns (Comment[]) {
        Comment[] rs;
        Comment comment;
        for(uint i = 1; i < comments.length; i++) {
            comment = comments[i];
            if (comment.eventId == eventId) {
                rs.push(comment);
            }
        }
        return rs;
    }

}