<?php
declare(script_types=1);


namespace App\Model\User\UseCase\SignUp\Request;

use App\Model\User\Entity\User\Email;
use App\Model\User\Entity\User\Id;
use App\Model\User\Entity\User\User;
use App\Model\User\Entity\User\UserRepository;
use App\Model\User\Service\SignUpConfirmTokenizer;
use App\Model\User\Service\ConfirmTokenSender;
use App\Model\User\Service\PasswordHasher;
use App\Model\Flasher;

class Handler
{


    /**
     * @var UserRepository
     */
    private $users;
    /**
     * @var PasswordHasher
     */
    private $hasher;
    /**
     * @var Flasher
     */
    private $flasher;
    /**
     * @var SignUpConfirmTokenizer
     */
    private $tokenizer;
    /**
     * @var ConfirmTokenSender
     */
    private $sender;

    public function __construct(UserRepository $users, PasswordHasher $hasher, SignUpConfirmTokenizer $tokenizer, ConfirmTokenSender $sender, Flasher $flasher)
    {

        $this->users = $users;
        $this->hasher = $hasher;
        $this->flasher = $flasher;
        $this->tokenizer = $tokenizer;
        $this->sender = $sender;
    }

    public function handle(Command $command): void
    {
        $email = new Email($command->email);

        if ($this->users->hasByEmail($email)) {
            throw new \DomainException('User already exists');
        }
        $user = new User(
            Id::next(),
            new \DateTimeImmutable(),
        );

        $user->signUpByEmail(
            $email,
            $this->hasher->hash($command->password),
            $token = $this->tokenizer->generate()
        );
        $this->users->add($user);
        $this->sender->send($email, $token);
        $this->flasher->flush();
    }
}