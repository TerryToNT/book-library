// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    
    event NewBook(string name, uint copies);

    struct Book {
        string name;
        uint copies;
    }
    
    struct BorrowedBook {
        uint bookId;
        bool isBorrowed;
    }
    
    Book[] public books;
 
    mapping (uint => address[]) public bookToBorrowers;
    mapping (address => BorrowedBook[]) public borrowerToBorrowedBooks;
    
    modifier isValidBook(string memory _name) {
        bytes memory tempBookName = bytes(_name);
        require(tempBookName.length > 0, 'Invalid book name!');
        _;
    }
    
    function addNewBook(Book calldata book) public onlyOwner isValidBook(book.name) {
        books.push(Book(book.name, book.copies));
        emit NewBook(book.name, book.copies);
    }
    
    function addCopiesToBook(uint _bookId, uint _copiesNumber) public onlyOwner {
        books[_bookId].copies += _copiesNumber;
    }
    
    function editBookName(uint _bookId, string memory _newBookName) public onlyOwner isValidBook(_newBookName) {
        books[_bookId].name = _newBookName;
    }
    
    function showAvailableBooks() public view returns(Book[] memory) {
        //TODO return only available books
        return books;
    }
    
    function borrowBook(uint _bookId) public {
        require(books[_bookId].copies > 0, 'There is no more copies of this book.');
        bool hasRecord = false;
        uint recordId;
        
        //TODO Try to optimise the logic to avoid the for loop and if statements. (Mapping?)
        for(uint i = 0; i < borrowerToBorrowedBooks[msg.sender].length; i++) {
            if (borrowerToBorrowedBooks[msg.sender][i].bookId == _bookId) {
                require(!borrowerToBorrowedBooks[msg.sender][i].isBorrowed, "You already borrowed this book.");
                hasRecord = true;
                recordId = i;
                break;
            }
        }
        
        books[_bookId].copies--;
        
        if (hasRecord) {
            borrowerToBorrowedBooks[msg.sender][recordId].isBorrowed = true;
        } else {
            borrowerToBorrowedBooks[msg.sender].push(BorrowedBook(_bookId, true));
        }
        
        //TODO add borrower only ones
        bookToBorrowers[_bookId].push(address(msg.sender));
    }
    
    function returnBook(uint _bookId) public {
        //TODO Try to optimise the logic to avoid the for loop and if statements.  (Mapping?)
        for(uint i = 0; i < borrowerToBorrowedBooks[msg.sender].length; i++) {
            if (borrowerToBorrowedBooks[msg.sender][i].bookId == _bookId) {
                if (borrowerToBorrowedBooks[msg.sender][i].isBorrowed) {
                    books[_bookId].copies++;
                    borrowerToBorrowedBooks[msg.sender][i].isBorrowed = false;
                    break;
                }
            }
        }
    }
    
    function showBookBorrowers(uint _bookId) public view returns(address[] memory) {
        //TODO return only unique address
        return bookToBorrowers[_bookId];
    }
}
