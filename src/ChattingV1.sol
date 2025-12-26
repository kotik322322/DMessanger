// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract ChattingV1 {
    struct Room {
        address[4] users;
        uint256 usersCount;
        bool status;
        uint256 messageId;
    }

    mapping(address => uint256) private _userChatId;
    mapping(uint256 => mapping(address => bool)) private _isUserInRoom;

    uint256 private _chatId;
    mapping(uint256 => Room) private _chatByRoom;

    error AddressAlreadyChatting();
    error AddressDidntJoinChatYet();
    error ChatAlreadyClosed();
    error InvalidChatId();
    error RoomIsFull();
    error InvalidMessageLength(uint256 maxLength, uint256 currentLength);

    event JoinedChat(address indexed user, uint256 chatId);
    event ChatCreated(address indexed user, uint256 chatId);
    event MessageSent(
        uint256 indexed chatId,
        address indexed sender,
        string message,
        uint256 timestamp,
        uint256 indexed messageId
    );

    modifier notInChat() {
        require(_userChatId[msg.sender] == 0, AddressAlreadyChatting());
        _;
    }

    function createChatRoom() external notInChat {
        _increaseChatId();
        _createChatRoom();
    }

    function joinChatByRoom(uint256 chatId) external notInChat {
        _joinChatRoom(chatId);
    }

    function sendMessage(string memory _message) external {
        uint256 chatIdByUser = _chatIdByUser[msg.sender];
        require(_isUserInRoom[chatIdByUser][msg.sender] == true, AddressDidntJoinChatYet());
        require(_chatByRoom[chatIdByUser].status == true, ChatAlreadyClosed());

        require(
            bytes(_message).length > 0 && bytes(_message).length <= 140,
            InvalidMessageLength(140, bytes(_message).length)
        );

        _chatByRoom[chatIdByUser].messageId += 1;

        emit MessageSent(
            chatIdByUser,
            msg.sender,
            _message,
            block.timestamp,
            _chatByRoom[chatIdByUser].messageId
        );
    }

    function leaveChatRoom() external {

        require(_chatIdByUser[msg.sender] > 0, AddressDidntJoinChatYet());

        uint256 userJoinedChatId = _chatIdByUser[msg.sender];

        Room storage room = _chatByRoom[userJoinedChatId];
        for (uint256 i = 0; i < room.usersCount; i++) {
            if (room.users[i] == msg.sender) {
                room.users[i] = room.users[room.usersCount - 1];
                delete room.users[room.usersCount - 1];
                room.usersCount -= 1;
                _chatIdByUser[msg.sender] = 0;
                _isUserInRoom[userJoinedChatId][msg.sender] = false;
                return;
            }
        }
        revert AddressDidntJoinChatYet();
    }

    // =====================private functions===============

    function _increaseChatId() private {
        ++_chatId;
    }

    function _createChatRoom() private {
        Room storage room = _chatByRoom[_chatId];
        room.users[room.usersCount] = msg.sender;
        room.status = true;
        room.usersCount++;

        _chatIdByUser[msg.sender] = _chatId;
        _isUserInRoom[_chatId][msg.sender] = true;

        emit ChatCreated(msg.sender, _chatId);
    }

    function _joinChatRoom(uint256 chatId) private {
        require(chatId <= _chatId && chatId > 0, InvalidChatId());

        Room storage room = _chatByRoom[chatId];

        require(room.status == true, ChatAlreadyClosed());
        require(room.usersCount < 4, RoomIsFull());

        _chatIdByUser[msg.sender] = chatId;
        room.users[room.usersCount] = msg.sender;
        room.usersCount++;

        _isUserInRoom[chatId][msg.sender] = true;

        emit JoinedChat(msg.sender, chatId);
    }
}
