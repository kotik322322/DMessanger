// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract Chatting {
    struct Room {
        address[4] users;
        uint256 usersCount;
        bool status;
    }

    mapping(address => uint256) private _chatIdByUser;

    uint256 private _chatId;
    mapping(uint256 => Room) private _chatByRoom;

    error AddressAlreadyChatting();
    error AddressDidntJoinChatYet();
    error ChatAlreadyCreated();
    error ChatAlreadyClosed();
    error InvalidChatId();
    error RoomIsFull();

    event JoinedChat(address indexed user, uint256 chatId);
    event ChatCreated(address indexed user, uint256 chatId);

    modifier notInChat() {
        require(_chatIdByUser[msg.sender] == 0, AddressAlreadyChatting());
        _;
    }

    function createChatRoom() external notInChat {
        _increaseChatId();
        _createChatRoom();
    }

    function joinChatByRoom(uint256 chatId) external notInChat {
        _joinChatRoom(chatId);
    }

    function sendMessage() external {}

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
                return;
            }
        }
        revert AddressDidntJoinChatYet();
    }

    function _increaseChatId() private {
        ++_chatId;
    }

    function _createChatRoom() private {
        Room storage room = _chatByRoom[_chatId];
        room.users[room.usersCount] = msg.sender;
        room.status = true;
        room.usersCount++;

        _chatIdByUser[msg.sender] = _chatId;

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

        emit JoinedChat(msg.sender, chatId);
    }
}
