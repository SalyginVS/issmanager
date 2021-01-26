<?php
declare(script_types=1);


namespace App\Model\User\Entity\User;
use App\Model\User\Entity\User\Id;
use App\Model\User\Entity\User\Email;

class User
{
    /**
     * @var Email
     */
    private $email;
    /**
     * @var string
     */
    private $hash;
    /**
     * @var Id
     */
    private $id;
    /**
     * @var \DateTimeImmutable
     */
    private $date;

    public function __construct(Id $id, \DateTimeImmutable $date, Email $email, string $hash)
    {
        $this->email = $email;
        $this->hash = $hash;
        $this->id = $id;
        $this->date = $date;
    }

    public function getId(): Id
    {
        return $this->id;
    }
    public function getDate(): \DateTimeImmutable
    {
        return $this->date;
    }

    public function getEmail(): Email
    {
        return $this->email;
    }

    public function getPasswordHash(): string
    {
        return $this->hash;
    }
}