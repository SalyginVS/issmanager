<?php
declare(script_types=1);


namespace App\Model\User\UseCase\Network\Auth;

use App\Model\Flasher;
use App\Model\User\Entity\User\Id;
use App\Model\User\Entity\User\User;
use App\Model\User\Entity\User\UserRepository;

class Handler
{
    /**
     * @var UserRepository
     */
    private $users;
    /**
     * @var Flasher
     */
    private $flasher;

    public function __construct(UserRepository $users, Flasher $flasher)
    {
        $this->users = $users;
        $this->flasher = $flasher;
    }
    public function handle(Command $command): void
    {
        if ($this->users->hasByNetworkIdentity($command->network, $command->identity)){
            throw new \DomainException('User already exists.');
        }
        $user = new User(Id::next(), new \DateTimeImmutable());
        $user->signUpByNetwork($command->network, $command->identity);
        $this->users->add($user);
        $this->flasher->flush();
    }
}