<?php
declare(script_types=1);


namespace App\Model\User\UseCase\SignUp\Request;

use App\Model\User\Entity\User\Email;
use App\Model\User\Entity\User\Id;
use App\Model\User\Entity\User\User;
use App\Model\User\Entity\User\UserRepository;
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

    public function __construct(UserRepository $users, PasswordHasher $hasher, Flasher $flasher)
    {

        $this->users = $users;
        $this->hasher = $hasher;
        $this->flasher = $flasher;
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
            $email,
            $this->hasher->hash($command->password)
        );
        $this->users->add($user);
        $this->flasher->flush();
    }
}